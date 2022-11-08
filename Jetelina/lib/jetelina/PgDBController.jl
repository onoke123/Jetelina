"""
    module: PgDBController

DB controller for PostgreSQL

contain functions
    open_connection()
    close_connection( conn )
    getTableList()
    dataInsertFromCSV( fname )
    getColumns()
    doInsert()
    doSelect()
    doUpdate()
    doDelete()

    create_jetelina_tables()
    create_jetelina_id_sequence()
    insert2JetelinaTableManager( tableName, columns )
    readJetelinatable()
    getJetelinaID( conn )
"""
module PgDBController

    using Genie, Genie.Renderer, Genie.Renderer.Json
    using CSV, LibPQ, DataFrames, IterTools, Tables
    using JetelinaLog, JetelinaReadConfig
    using PgDataTypeList

    """
    """
    function create_jetelina_table()
        create_jetelina_table_manager_str = """
            create table if not exists jetelina_table_manager(
                jetelina_id varchar(256), table_name varchar(256), columns varchar(256)
            );
        """
        conn = open_connection()
        execute( conn, create_jetelina_table_manager_str )
        close_connection( conn )
    end

    """
    """
    function create_jetelina_id_sequence()
        create_jetelina_id_sequence = """
            create sequence jetelina_id;
        """
        conn = open_connection()
        execute( conn, create_jetelina_id_sequence )
        close_connection( conn )
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
    function close_connection( conn )
        close( conn )
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
        global Df_JetelinaTableManager = DataFrame(columntable(LibPQ.execute(conn, sql)))  
        close_connection( conn )
        if debugflg
            @info "Df_JetelinaTableManager: " Df_JetelinaTableManager
        end

#        return df
    end

    """
        function getTableList()

    # Arguments
    return: json data of table list

    get all table name from public 'schemaname'
    """
    function getTableList()
        df = _getTableList()
        ret = json( Dict( "Jetelina" => copy.( eachrow( df ))))
        return ret
    end

    function _getTableList()
        conn = open_connection()
        # schemanameをpublicに固定している。これはプロトコルでいいかな。
        # システムはpublicで作るとして、importも"publicで"としようか。
        table_str = "select tablename from pg_tables where schemaname='public'"
        df = DataFrame(columntable(LibPQ.execute(conn, table_str)))  
        close_connection( conn )

        return df
    end

    """
        function getJetelinaID( conn )
        
    # Arguments
    - `conn: Object`: connection object

    get seaquence number from jetelina_id table
    """
    function getJetelinaID( conn )
        sql = """
            select nextval('jetelina_id');
        """
        sequence_number = columntable(execute( conn, sql ))

        #===
            ここはちょっと説明が要る。
            sequence_numberは Union{Missing, Int64}[51]　になっていて
            nextval()の値は[51]の51になっている。なので、
            sequence_number[1] -> Union{Int64}[51]
            sequence_number[1][1] -> 51
            というわけ。メンドウだな。
        ===#
        return "j" * string( sequence_number[1][1] )
    end

    """
    function insert2JetelinaTableManager( tableName, columns )

        # Arguments
        - `tableName: String`: table name of insertion
        - `columns: Array`: vector arrya for insert column data

        columns of tableName insert into Jetelina_table_manager  
    """
    function insert2JetelinaTableManager( tableName, columns )
        conn = open_connection()

        jetelina_id = getJetelinaID( conn )

        for i = 1:length(columns)
            c = columns[i]
            values_str = "'$jetelina_id','$tableName','$c'"
            
            if debugflg 
                @info "insert str:" values_str
            end

            insert_str = """
                insert into Jetelina_table_manager values($values_str);
            """
            execute( conn, insert_str )
        end

        close_connection( conn )

        # Df_JetelinaTableManagerを更新する
        readJetelinatable()
    end

    """
        function dataInsertFromCSV( fname )

    # Arguments
    - `fname: String`: csv file name

    CSV file data insert into the table that is orderd by csv file name
    """
    function dataInsertFromCSV( fname )
        df = DataFrame( CSV.File(fname) )

        # special column 'jetelina_delte_flg' is added to columns 
        insertcols!( df, :jetelina_delete_flg=>0 )
        
        column_name = names(df)

        column_type = eltype.(eachcol(df))

        column_type_string = Array{Union{Nothing,String}}(nothing,size(column_name))
        column_str = string()
        #===
            要は、create table文の　"id integer, name varchar(36)...の文を作るための処理であるぞと
        ===#
        for i = 1:length(column_name)
            column_type_string[i] = PgDataTypeList.getDataType( column_type[i] )
            column_str = string( column_str," ", column_name[i]," ", column_type_string[i] )
            if 0 < i < length( column_name )
                column_str = string( column_str * "," )
#            elseif i == length( column_name )
            end
        end

        if debugflg
            @info "col str to create table: ", column_str
        end

        #===
            new table name is the csv file name with deleting the suffix  
                ex. /home/upload/test.csv -> splitdir() -> ("/home/upload","test.csv") -> splitext() -> ("test",".csv")
        ===#
        tableName = splitext( splitdir( fname )[2] )[1]

        #===
            ここで一度、同じ名前のtableの存在を確認する。
            でもそれはcreate tableのためではなくて(だって、not existsしてるし)、
            その後の insert2JetelinaTableManager() 処理のため。
        ===#
        df_tl = _getTableList()
        DataFrames.filter!( row-> row.tablename == tableName,df_tl )

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
            execute( conn, create_table_str )
        catch
            err
            println(err)
        end
        #===
            then get column from the created table, because the columns are order by csv file, thus they can get after
            created the table
        ===#
        sql = """   
            SELECT
                *
            from $tableName
            LIMIT 1
            """        
        df0 = DataFrame(columntable(LibPQ.execute(conn, sql)))  
        cols = map(x -> x, names(df0))
        select!(df, cols)

        # create rows
        row_strings = imap(eachrow(df)) do row
            join((ismissing(x) ? "null" : x for x in row), ",")*"\n"
        end

        copyin = LibPQ.CopyIn("COPY $tableName FROM STDIN (FORMAT CSV);", row_strings)
        execute(conn, copyin)
        # これは
        #columns = getColumns( conn, tableName )
        close_connection( conn )

        if isempty( df_tl )
            # manage to jetelina_table_manager
            insert2JetelinaTableManager( tableName, names(df0) )
        end
    end

    """
        function getColumns( fname )

    # Arguments
    - `tableName: String`: DB table name
    """
    function getColumns( tableName )
        sql = """   
            SELECT
                *
            from $tableName
            LIMIT 1
            """        
        conn = open_connection()
        df = DataFrame(columntable(LibPQ.execute(conn, sql)))  
        close_connection( conn )
        cols = map(x -> x, names(df))
        @info "cols:", cols
        select!(df, cols)
        
        return json( Dict( "Jetelina" => copy.( eachrow( df ))))
    end

    function doInsert()
    end

    function doSelect()
    end

    function doUpdate()
    end

    function doDelete()
    end
end