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
    insert2JetelinaTableManager( tableName, columns )
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
        function getTableList()

    # Arguments
    return: json data of table list

    get all table name from public 'schemaname'
    """
    function getTableList()
        conn = open_connection()
        # schemanameをpublicに固定している。これはプロトコルでいいかな。
        # システムはpublicで作るとして、importも"publicで"としようか。
        table_str = "select tablename from pg_tables where schemaname='public'"
        df0 = DataFrame(columntable(LibPQ.execute(conn, table_str)))  
        ret = json( Dict( "Jetelina" => copy.( eachrow( df0 ))))
        close_connection( conn )
        return ret
    end

    """
    function insert2JetelinaTableManager( tableName, columns )

        # Arguments
        - `tableName: String`: table name of insertion
        - `columns: Array`: vector arrya for insert column data

        columns of tableName insert into Jetelina_table_manager  
    """
    function insert2JetelinaTableManager( tableName, columns )
        jetelina_id = "j1" # ここはユニークでなければならない。後でちゃんと番号を取ろう。とりあえず今は固定。

        conn = open_connection()

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

        if debugflg
            @info "csv file: $fname"
            @info "df:", df
            @info "col name:" column_name, typeof(column_name)
            @info "col type:" column_type, typeof(column_type)
            @info "col sample: name/type/num_of_cols is " column_name[1], column_type[1], size(column_name)
        end

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
        create_table_str = """
            create table if not exists $tableName(
                $column_str   
            );
        """
        conn = open_connection()
        execute( conn, create_table_str )
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
        columns = getColumns( conn, tableName )
        close_connection( conn )

        # manage to jetelina_table_manager
        insert2JetelinaTableManager( tableName, names(df0) )

        return columns
    end

    """
        function getColumns( conn, fname )

    # Arguments
    - `conn: Object`: Data Base connection object
    - `tableName: String`: DB table name
    """
    function getColumns( conn, tableName )
        sql = """   
            SELECT
                *
            from $tableName
            LIMIT 1
            """        
        df = DataFrame(columntable(LibPQ.execute(conn, sql)))  
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