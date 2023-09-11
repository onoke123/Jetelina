"""
    module: PgDBController

    Author: Ono keiji
    Version: 1.0
    Description:
        DB controller for PostgreSQL

    functions
        create_jetelina_tables()
        create_jetelina_id_sequence()
        open_connection()
        close_connection(conn::LibPQ.Connection)
        readJetelinatable()
        getTableList(s::String)
        getJetelinaSequenceNumber(t::Integer)
        insert2JetelinaTableManager(tableName::String, columns::Array)
        dataInsertFromCSV(fname::String)
        dropTable(tableName::String)
        getColumns(tableName::String)
        doInsert()
        doSelect(sql::String,mode::String)
        doUpdate()
        doDelete()
        getUserAccount(s::String)
        measureSqlPerformance()
"""
module PgDBController

using Genie, Genie.Renderer, Genie.Renderer.Json
using CSV, LibPQ, DataFrames, IterTools, Tables
using JetelinaLog, JetelinaReadConfig
using PgDataTypeList
using JetelinaFiles
using SQLSentenceManager

export create_jetelina_tables,create_jetelina_id_sequence,open_connection,close_connection,readJetelinatable,
getTableList,getJetelinaSequenceNumber,insert2JetelinaTableManager,dataInsertFromCSV,dropTable,getColumns,doInsert,
doSelect,doUpdate,doDelete,getUserAccount,measureSqlPerformance


"""
function create_jetelina_table

    create 'jetelina_table_manager' table.
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
function create_jetelina_id_sequence()

    create 'jetelina_id' sequence.
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

# Arguments
- return: LibPQ.Connection object
"""
function open_connection()
    return conn = LibPQ.Connection("""host = '$JetelinaDBhost' 
        port = '$JetelinaDBport'
        user = '$JetelinaDBuser'
        password = '$JetelinaDBpassword'
        sslmode = '$JetelinaDBsslmode'
        dbname = '$JetelinaDBname' """)
end

"""
function close_connection(conn::LibPQ.Connection)

    close the DB connection

# Arguments
- `conn:LibPQ.Connection`: LibPQ.Connection object

"""
function close_connection(conn::LibPQ.Connection)
    close(conn)
end

"""
function readJetelinatable()

    read all data from jetelina_table_manager then put it into Df_JetelinaTableManager DataFrame 

# Arguments
- return: boolean:  true->success, false->fail
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
function getTableList(s::String)

    get all table name from public 'schemaname'

# Arguments
- `s:String`: 'json' -> required JSON form to return
              'dataframe' -> required DataFrames form to return
- return: table list in json or DataFrame

"""
function getTableList(s::String)
    df = _getTableList()
    if s == "json"
        return json(Dict("Jetelina" => copy.(eachrow(df))))
    elseif s == "dataframe"
        return df
    end
end
"""
function _getTableList()

    get table list then put it into DataFrame object. this is a private function, but can access from others
    fixing as 'public' in schemaname. this is the protocol.

# Arguments
- return: DataFrame object. empty if got fail.
"""
function _getTableList()
    df = DataFrame()
    conn = open_connection()
    # Fixing as 'public' in schemaname. This is the protocol.
    table_str = """select tablename from pg_tables where schemaname='public'"""
    try
        df = DataFrame(columntable(LibPQ.execute(conn, table_str)))
        # do not include 'jetelina_table_manager and usertable in the return
        DataFrames.filter!(row -> row.tablename != "jetelina_table_manager" && row.tablename != "usertable", df)
    catch err
        JetelinaLog.writetoLogfile("PgDBController._getTableList() error: $err")
        return DataFrame() # return empty DataFrame if got fail
    finally
        close_connection(conn)
    end

    return df
end
"""
function getJetelinaSequenceNumber(t::Integer)

    get seaquence number from jetelina_id table

# Arguments
- `t: Integer`  : type order  0-> jetelina_id, 1-> jetelian_sql_sequence
- return: 0< sequence number   -1 fail
"""
function getJetelinaSequenceNumber(t::Integer)
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
function _getJetelinaSequenceNumber(conn::LibPQ.Connection, t::Integer)

    get seaquence number from jetelina_id table, but this is a private function.
    this function will never get fail, expectedly.:-P

# Arguments
- `conn: Object`: connection object
- `t: Integer`  : type order  0-> jetelina_id, 1-> jetelian_sql_sequence
- return:Integer: sequence number 
"""
function _getJetelinaSequenceNumber(conn::LibPQ.Connection, t::Integer)
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
        Tips:
        this sequence_number is a type of Union{Missing,Int64}{51} for example.
        wanted nextval() is {51}, then 
            sequence_number[1] -> Union{Int64}[51]
            sequence_number[1][1] -> 51
    ===#
    return sequence_number[1][1]
end

"""
function insert2JetelinaTableManager(tableName::String, columns::Array )

    insert columns of 'tableName' into Jetelina_table_manager  

# Arguments
- `tableName: String`: table name of insertion
- `columns: Array`: vector arrya for insert column data
- return: boolean: fail if got error. nothing return in the caes of success
"""
function insert2JetelinaTableManager(tableName::String, columns::Array)
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

    # update Df_JetelinaTableManager
    readJetelinatable()
end

"""
function dataInsertFromCSV(fname::String)

    insert csv file data ordered by 'fname' into table. the table name is the csv file name.

# Arguments
- `fname: String`: csv file name
- return: boolean: true -> success, false -> get fail
"""
function dataInsertFromCSV(fname::String)
    df = DataFrame(CSV.File(fname))
    rename!(lowercase,df)
    # special column 'jetelina_delte_flg' is added to columns 
    insertcols!(df, :jetelina_delete_flg => 0)

    column_name = names(df)

    column_type = eltype.(eachcol(df))
    column_type_string = Array{Union{Nothing,String}}(nothing, length(column_name))
    column_str = string()
    insert_str = string()
    update_str = string()
    tablename_arr = []
    #===
        make the sentece of sql( "id integer, name varchar(36)...")
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
        check if the same name table already exists.
        this is not for create sql, but for insert2JetelinaTableManager().
    ===#
    df_tl = _getTableList()
    DataFrames.filter!(row -> row.tablename == tableName, df_tl)

    #===
        Tips:
        create table with 'not exists'.
        then insert csv data to there. this is because of forgiving adding data to the same table.
        put isempty(df_tl) in there as same as insert2JetelinaTableManager if it does not forgive it.
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
        # do not close the connection because of resuming below yet.
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
    rename!(lowercase,df0)
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
        # ok. close the connection finally
        close_connection(conn)
    end
    #===
        Tips:
        cols(see above) is ["id", "name", "sex", "age", "ave", "jetelina_delete_flg"], so can use it when
        wanna use column name, but need to judge the data type both the case of 'insert' and 'update', 
        that why do not use cols here. writing select sentence is done in PostDataController.postDataAcquire(). 
    ===#
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
function dropTable(tableName::String)

    drop the table and delete its related data from jetelina_table_manager table

# Arguments
- `tableName: String`: ordered table name
- return: boolean: true -> success, false -> get fail
"""
function dropTable(tableName::String)
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

    # update SQL list
    SQLSentenceManager.deleteFromlist(tableName)

    return true
end

"""
function getColumns(tableName::String)

    get columns name of ordereing table.

# Arguments
- `tableName: String`: DB table name
- return: String: in success -> column data in json, in fail -> ""
"""
function getColumns(tableName::String)
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
"""
function doInsert()

    insert json data into table, but not imprement yet.
"""
function doInsert()
end

"""
function doSelect(sql::String,mode::String)

    execute select data by ordering sql sentence, but get sql execution time of ordered sql if 'mode' is 'measure'.
    'mode=mesure' is for the condition panel feture.

# Arguments
- `sql: String`: execute sql sentense
- `mode: String`: "run"->running mode  "measure"->measure speed. only called by measureSqlPerformance()
- return: no 'mesure' mode -> tuple(boolean,string in json). json string is missing when getting fail
          'mesure' mode -> exectution time of tuple(max,min,mean) 
"""
function doSelect(sql::String,mode::String)
    conn = open_connection()
    try
        if mode == "measure"
            #===
                aquire data types are max,best and mean
            ===#
            exetime = []
            looptime = 10
            for loop in 1:looptime
                stats = @timed z = LibPQ.execute(conn, sql)
                push!(exetime,stats.time)
            end

            return findmax(exetime), findmin(exetime), sum(exetime)/looptime
        end

        df = DataFrame(columntable(LibPQ.execute(conn, sql)))
        j = json(Dict("Jetelina" => copy.(eachrow(df))))
        return true, j
    catch err
        println(err)
        JetelinaLog.writetoLogfile("PgDBController.doSelect() with $mode $sql error : $err")
        return false
    finally
        # close the connection finally
        close_connection(conn)
    end
end
"""
function doUpdate()

    update json data into table, but not imprement yet.
"""
function doUpdate()
end
"""
function doDelete()

    delete data ordered table, but not imprement yet.
"""
function doDelete()
end
"""
function getUserAccount(s::String)

    get user account for authentication.
    
# Arguments
- `s::String`:  user information. login account or first name or last name.
- return: success -> user data in json, fail -> ""
"""
function getUserAccount(s::String)
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

    measure exectution time of all listed sql sentences. then write it out to JetelinaSqlPerformancefile.
"""
function measureSqlPerformance()
    #===
        Tips:
        Use JetelinaSqlList file here because the convenient Df_JetelinaSqlList is in the Genie zone,
        then need to use it via Web, it gives a reguration to use it in other process, for example cron.
    ===#
    sqlFile = getFileNameFromConfigPath(JetelinaSQLListfile)
    sqlPerformanceFile = getFileNameFromConfigPath(JetelinaSqlPerformancefile)

    open(sqlPerformanceFile, "w") do f
        println(f,string(JetelinaFileColumnApino,',',JetelinaFileColumnMax,',',JetelinaFileColumnMin,',',JetelinaFileColumnMean))
        df = CSV.read( sqlFile, DataFrame )
        for i in 1:size(df,1)
            if startswith(df.apino[i] ,"js")
                p = doSelect(df.sql[i],"measure")
                fno::String=df.apino[i]
                fmax::Float64=p[1][1]
                fmin::Float64=p[2][1]
                fmean::Float64=p[3]
                s = """$fno,$fmax,$fmin,$fmean"""
                println(f,s)
            end
        end
    end
end

end