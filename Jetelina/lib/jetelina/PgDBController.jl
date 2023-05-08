"""
    module: PgDBController

DB controller for PostgreSQL

contain functions
    open_connection()
    close_connection( conn )
    getTableList()
    dataInsertFromCSV( fname )
    dropTable( tableName )
    getColumns()
    doInsert()
    doSelect()
    doUpdate()
    doDelete()

    create_jetelina_tables()
    create_jetelina_id_sequence()
    insert2JetelinaTableManager( tableName, columns )
    readJetelinatable()
    getJetelinaSequenceNumber( conn, t )
    getUserAccount( s )
    measureSqlPerformance()
"""
module PgDBController

using Genie, Genie.Renderer, Genie.Renderer.Json
using CSV, LibPQ, DataFrames, IterTools, Tables
using JetelinaLog, JetelinaReadConfig
using PgDataTypeList
using JetelinaFiles
using SQLSentenceManager

"""
"""
function create_jetelina_table()
    create_jetelina_table_manager_str = """
        create table if not exists jetelina_table_manager(
            jetelina_id varchar(256), table_name varchar(256), columns varchar(256)
        );
    """
    conn = open_connection()
    try
        execute(conn, create_jetelina_table_manager_str)
    catch err
        JetelinaLog.writetoLogfile("PgDBController.create_jetelina_table() error: $err")
    finally
        close_connection(conn)
    end
end

"""
"""
function create_jetelina_id_sequence()
    create_jetelina_id_sequence = """
        create sequence jetelina_id;
    """
    conn = open_connection()
    try
        execute(conn, create_jetelina_id_sequence)
    catch err
        JetelinaLog.writetoLogfile("PgDBController.create_jetelina_id_sequence() error: $err")
    finally
        close_connection(conn)
    end
end

"""
    function open_connection()

open connection to the DB.
connection parameters are set by global variables.
"""
function open_connection()
    #===
    @info "host = '$JetelinaDBhost' 
    port = '$JetelinaDBport'
    user = '$JetelinaDBuser'
    password = '$JetelinaDBpassword'
    sslmode = '$JetelinaDBsslmode'
    dbname = '$JetelinaDBname' "
    ===#
    conn = LibPQ.Connection("""host = '$JetelinaDBhost' 
        port = '$JetelinaDBport'
        user = '$JetelinaDBuser'
        password = '$JetelinaDBpassword'
        sslmode = '$JetelinaDBsslmode'
        dbname = '$JetelinaDBname' """)
end

"""
    function close_connection( conn )

# Arguments
- `conn: Object`: connection object

close the DB connection
"""
function close_connection(conn)
    close(conn)
end

"""
    function readJetelinatable()

read all data from jetelina_table_manager then put it into Df_JetelinaTableManager DataFrame 
"""
function readJetelinatable()
    sql = """   
        select
            *
        from jetelina_table_manager
    """
    conn = open_connection()
    try
        global Df_JetelinaTableManager = DataFrame(columntable(LibPQ.execute(conn, sql)))
    catch err
        JetelinaLog.writetoLogfile("PgDBController.readJetelinatable() error: $err")
        return false
    finally
        close_connection(conn)
    end

    if debugflg
        @info "Df_JetelinaTableManager: " Df_JetelinaTableManager
    end

    return true
end

"""
    function getTableList()

# Arguments
s:String: 'json' -> return is JSON form
          'dataframe' -> return is DataFrames form
return: json data of table list

get all table name from public 'schemaname'
"""
function getTableList(s::String)
    df = _getTableList()
    if s == "json"
        return json(Dict("Jetelina" => copy.(eachrow(df))))
    elseif s == "dataframe"
        return df
    end
end

function _getTableList()
    df = DataFrame()
    conn = open_connection()
    # schemanameをpublicに固定している。これはプロトコルでいいかな。
    # システムはpublicで作るとして、importも"publicで"としようか。
    table_str = "select tablename from pg_tables where schemaname='public'"
    try
        df = DataFrame(columntable(LibPQ.execute(conn, table_str)))
        # クライアントに提供するtable listには jetelina_table_manager　は含まない。
        DataFrames.filter!(row -> row.tablename != "jetelina_table_manager", df)
    catch err
        JetelinaLog.writetoLogfile("PgDBController._getTableList() error: $err")
        return DataFrame() # null のDataFrameなんか返しちゃったりして
    finally
        close_connection(conn)
    end

    return df
end
"""
    function getJetelinaSequenceNumber( t )
    
# Arguments
- `t: Integer`  : type order  0-> jetelina_id, 1-> jetelian_sql_sequence
get seaquence number from jetelina_id table
"""
function getJetelinaSequenceNumber(t)
    conn = open_connection()
    ret = -1
    try
        ret = _getJetelinaSequenceNumber(conn, t)
    catch err
        JetelinaLog.writetoLogfile("PgDBController.getJetelinaSequenceNumber() error: $err")
    finally
        close_connection(conn)
    end

    return ret
end

"""
    function _getJetelinaSequenceNumber( conn, t )
    
# Arguments
- `conn: Object`: connection object
- `t: Integer`  : type order  0-> jetelina_id, 1-> jetelian_sql_sequence
get seaquence number from jetelina_id table
"""
function _getJetelinaSequenceNumber(conn, t)
    sql = ""

    if t == 0
        sql = """
            select nextval('jetelina_id');
        """
    elseif t == 1
        sql = """
            select nextval('jetelina_sql_sequence');
        """
    end

    sequence_number = columntable(execute(conn, sql))

    #===
        ここはちょっと説明が要る。
        sequence_numberは Union{Missing, Int64}[51]　になっていて
        nextval()の値は[51]の51になっている。なので、
        sequence_number[1] -> Union{Int64}[51]
        sequence_number[1][1] -> 51
        というわけ。メンドウだな。
    ===
    if t == 0
        return "j" * string( sequence_number[1][1] )
    elseif t == 1
        return "js" * string( sequence_number[1][1] )
    end
    ===#
    return sequence_number[1][1]
end

"""
function insert2JetelinaTableManager( tableName, columns )

    # Arguments
    - `tableName: String`: table name of insertion
    - `columns: Array`: vector arrya for insert column data

    columns of tableName insert into Jetelina_table_manager  
"""
function insert2JetelinaTableManager(tableName, columns)
    conn = open_connection()

    try
        jetelina_id = _getJetelinaSequenceNumber(conn, 0)

        for i = 1:length(columns)
            c = columns[i]
            values_str = "'$jetelina_id','$tableName','$c'"

            if debugflg
                @info "insert str:" values_str
            end

            insert_str = """
                insert into Jetelina_table_manager values($values_str);
            """
            execute(conn, insert_str)
        end
    catch err
        JetelinaLog.writetoLogfile("PgDBController.insert2JetelinaTableManager() error: $err")
        return false
    finally
        close_connection(conn)
    end

    # Df_JetelinaTableManagerを更新する
    readJetelinatable()
end

"""
    function dataInsertFromCSV( fname )

# Arguments
- `fname: String`: csv file name

CSV file data insert into the table that is orderd by csv file name
"""
function dataInsertFromCSV(fname)
    df = DataFrame(CSV.File(fname))

    # special column 'jetelina_delte_flg' is added to columns 
    insertcols!(df, :jetelina_delete_flg => 0)

    column_name = names(df)

    column_type = eltype.(eachcol(df))

    column_type_string = Array{Union{Nothing,String}}(nothing, size(column_name))
    column_str = string()
    insert_str = string()
    update_str = string()
    tablename_arr = []
    #===
        要は、create table文の　"id integer, name varchar(36)...の文を作るための処理であるぞと
    ===#
    for i = 1:length(column_name)
        cn = column_name[i]
        column_type_string[i] = PgDataTypeList.getDataType(column_type[i])
        column_str = string(column_str, " ", column_name[i], " ", column_type_string[i])
        if startswith(column_type_string[i], "varchar")
            #string data
            insert_str = string(insert_str, "'$cn'")
            update_str = string(update_str, "$cn='d_$cn'")
        else
            #number data
            insert_str = string(insert_str, "$cn")
            update_str = string(update_str, "$cn=d_$cn")
        end

        if 0 < i < length(column_name)
            column_str = string(column_str * ",")
            insert_str = string(insert_str * ",")
            update_str = string(update_str * ",")
        end
    end

    if debugflg
        @info "col str to create table: ", column_str
    end

    #===
        new table name is the csv file name with deleting the suffix  
            ex. /home/upload/test.csv -> splitdir() -> ("/home/upload","test.csv") -> splitext() -> ("test",".csv")
    ===#
    tableName = splitext(splitdir(fname)[2])[1]

    #===
        ここで一度、同じ名前のtableの存在を確認する。
        でもそれはcreate tableのためではなくて(だって、not existsしてるし)、
        その後の insert2JetelinaTableManager() 処理のため。
    ===#
    df_tl = _getTableList()
    DataFrames.filter!(row -> row.tablename == tableName, df_tl)

    #===
        "not exists"条件をつけてtableを作成する。
        その後csvファイルデータをinsertするが、これは同一tableに「追加」
        を認めているから。もし「追加」を認めない場合は、insert2JetelinaTableManager()
        実行処理条件のところと同じく isempty( df_tl ) 判定を入れればいい。
    ===#
    create_table_str = """
        create table if not exists $tableName(
            $column_str   
        );
    """
    conn = open_connection()
    try
        execute(conn, create_table_str)
    catch err
        close_connection(conn)
        println(err)
        JetelinaLog.writetoLogfile("PgDBController.dataInsertFromCSV() with $fname error : $err")
        return false
    finally
        #正常な場合まだ下でconnを使うのでここでは閉じない
        #close_connection( conn )
    end
    #===
        then get column from the created table, because the columns are order by csv file, thus they can get after
        created the table
    ===#
    sql = """   
        SELECT
            *
        from $tableName
        """
    df0 = DataFrame(columntable(LibPQ.execute(conn, sql)))
    cols = map(x -> x, names(df0))
    select!(df, cols)

    # create rows
    row_strings = imap(eachrow(df)) do row
        join((ismissing(x) ? "null" : x for x in row), ",") * "\n"
    end

    copyin = LibPQ.CopyIn("COPY $tableName FROM STDIN (FORMAT CSV);", row_strings)
    try
        execute(conn, copyin)
    catch err
        println(err)
        JetelinaLog.writetoLogfile("PgDBController.dataInsertFromCSV() with $fname error : $err")
        return false
    finally
        #ここまで来たらconnを閉じる
        close_connection(conn)
    end

    # cols: ["id", "name", "sex", "age", "ave", "jetelina_delete_flg"]みたいに入っているのでカラムを使いたいときはこれを使おう
    # と思ったけど、insert文もupdate文もデータのタイプを判断しないといけないから、colsではなくその上の
    # select文の書き込みはPostDataCOntroller.postDataAcquire()　でやっている
    push!(tablename_arr, tableName)
    insert_str = """insert into $tableName values($insert_str)"""
    if debugflg
        @info "insert sql: " insert_str
    end

    SQLSentenceManager.writeTolist(insert_str, tablename_arr)

    # update
    update_str = """update $tableName set $update_str"""
    if debugflg
        @info "update sql: " update_str
    end

    SQLSentenceManager.writeTolist(update_str, tablename_arr)

    # delete
    delete_str = """delete from $tableName"""
    if debugflg
        @info "delete sql: " delete_str
    end

    SQLSentenceManager.writeTolist(delete_str, tablename_arr)

    if isempty(df_tl)
        # manage to jetelina_table_manager
        insert2JetelinaTableManager(tableName, names(df0))
    end

    return true
end

"""
function dropTable( tableName )

# Arguments
- `tableName: String`: name of the table

drop the table and delete its related data from jetelina_table_manager table
"""
function dropTable(tableName)
    # drop the tableName
    drop_table_str = """
        drop table $tableName
    """

    # delete the related data from jetelina_table_manager
    delete_data_str = """
        delete from jetelina_table_manager where table_name = '$tableName'
    """
    conn = open_connection()

    try
        execute(conn, drop_table_str)
        execute(conn, delete_data_str)
    catch err
        println(err)
        JetelinaLog.writetoLogfile("PgDBController.dropTable() with $tableName error : $err")
        return false
    finally
        close_connection(conn)
    end

    # SQLリストを処理する
    SQLSentenceManager.deleteFromlist(tableName)

    return true
end

"""
    function getColumns( fname )

# Arguments
- `tableName: String`: DB table name
"""
function getColumns(tableName)
    j = ""

    sql = """   
        SELECT
            *
        from $tableName
        LIMIT 1
        """
    conn = open_connection()
    try
        df = DataFrame(columntable(LibPQ.execute(conn, sql)))
        cols = map(x -> x, names(df))
        select!(df, cols)

        j = json(Dict("tablename" => "$tableName", "Jetelina" => copy.(eachrow(df))))
    catch err
        JetelinaLog.writetoLogfile("PgDBController.getColumns() with $tableName error : $err")
    finally
        close_connection(conn)
    end

    return j
end

function doInsert()
end

"""
    function doSelect( sql,flg )

# Arguments
- `sql: String`: execute sql sentense
- `mode: String`: "run"->running mode  "measure"->measure speed. only called by measureSqlPerformance()
"""
function doSelect(sql,mode)
    conn = open_connection()
    try
        if mode == "measure"
            exetime = 0.0
            looptime = 10
            for loop in 1:looptime
                stats = @timed z = LibPQ.execute(conn, sql)
                @info stats.time
                exetime += stats.time
            end

            @info "exetime: " exetime

            return exetime/looptime 
        end

        df = DataFrame(columntable(LibPQ.execute(conn, sql)))
        j = json(Dict("Jetelina" => copy.(eachrow(df))))
        return true, j
    catch err
        println(err)
        JetelinaLog.writetoLogfile("PgDBController.doSelect() with $mode $sql error : $err")
        return false
    finally
        #ここまで来たらconnを閉じる
        close_connection(conn)
    end
end

function doUpdate()
end

function doDelete()
end

function getUserAccount(s)
    j = ""

    sql = """   
    SELECT
        *
    from usertable
    where (login = '$s')or(firstname='$s')or(lastname='$s')
    """
    conn = open_connection()
    try
        df = DataFrame(columntable(LibPQ.execute(conn, sql)))
        j = json(Dict("Jetelina" => copy.(eachrow(df))))
    catch err
        JetelinaLog.writetoLogfile("PgDBController.getUserAccount() with $s error : $err")
    finally
        close_connection(conn)
    end

    return j
end

"""
    function measureSqlPerformance()

# Arguments
# Description
    measure sql exectution time
"""
function measureSqlPerformance()

    doSelect(sql,"measure")
end

end