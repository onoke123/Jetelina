"""
    module: PgDBController

DB controller for PostgreSQL

contain functions
    open_connection()
    close_connection( conn )
    getTableList()
    dataInsertFromCSV( fname )
"""
module PgDBController

    using Genie, Genie.Renderer, Genie.Renderer.Json
    using CSV, LibPQ, DataFrames, IterTools, Tables
    using PgDataTypeList
    using JetelinaReadConfig

    """
        function open_connection()

    open connection to the DB.
    connection parameters are set by global variables.
    """
    function open_connection()
        @info "host = '$JetelinaDBhost' 
        port = '$JetelinaDBport'
        user = '$JetelinaDBuser'
        password = '$JetelinaDBpassword'
        sslmode = '$JetelinaDBsslmode'
        dbname = '$JetelinaDBname' "
        
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
        function dataInsertFromCSV( fname )

    # Arguments
    - `fname: String`: csv file name
    """
    function dataInsertFromCSV( fname )
        df = CSV.read( fname, DataFrame )

        column_name = names(df)

        column_type = eltype.(eachcol(df))
        if debugflg == true
            @info "csv file: $fname"
            @info df
            @info column_name
            @info column_type
            @info column_name[1], column_type[1], size(column_name)
        end

        column_type_string = Array{Union{Nothing,String}}(nothing,size(column_name))

        column_str = string()

        for i = 1:length(column_name)
            column_type_string[i] = PgDataTypeList.getDataType( column_type[i] )

            column_str = string( column_str," ", column_name[i]," ", column_type_string[i] )
            if 0 < i < length( column_name )
                column_str = string( column_str * "," )
            elseif i == length( column_name )
            end
        end

        if debugflg == true
            @info column_str
        end

        # new table name is the csv file name
        tn = splitdir( fname )
        tableName = tn[2]

        create_table_str = """
            create table if not exists $tableName(
                $column_str   
            );
        """

        conn = open_connection()

        execute( conn, create_table_str )

        sql = """   
            SELECT
                *
            from $tableName
            LIMIT 1
            """        
        df0 = DataFrame(columntable(LibPQ.execute(conn, sql)))  
        cols = map(x -> x, names(df0))
        select!(df, cols)
        #select(df, cols)

        # create rows
        row_strings = imap(eachrow(df)) do row
            join((ismissing(x) ? "null" : x for x in row), ",")*"\n"
        end

        copyin = LibPQ.CopyIn("COPY $tableName FROM STDIN (FORMAT CSV);", row_strings)

        execute(conn, copyin)

        close_connection( conn )
    end

    """
        function getalldbdata( tablename )
        
    # Arguments
    - `tablename: String`: table name

    get all data from the table
    """
    function getalldbdata( tablename )
        json( Dict( "Jetelina" => copy.( eachrow( select_data( tablename, "" ) ))))
    end

    """
        function select_data( tablename, condition )

    # Arguments
    - `tablename: String`: table name
    - `condition: String`: where sentence in SQL

    execute select sentence in SQL order by the table name and where condition.
    condition variable expects like
          ex. where a = b
              where (1<a)and(b<5)
    """
    function select_data( tablename, condition )
        conn = open_connection()

        where_sentence::String = ""
        if 0 < length( condition )
            where_sentence = "where $condition"
        end

        sql = "select * from $tablename $where_sentence"
        df = DataFrame(columntable(LibPQ.execute(conn, sql)))
        close_connection( conn )
        return df
    end
end