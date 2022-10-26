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
    #===
        create table & data insert to DB from reading csv file
    ===#
    function dataInsertFromCSV( fname )
        if debugflg == true
            @info "csv file: $fname"
        end

        df = CSV.read( fname, DataFrame )
        if debugflg == true
            @info df
        end

        column_name = names(df)
        if debugflg == true
            @info column_name
        end

        column_type = eltype.(eachcol(df))
        if debugflg == true
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

        #===
            new table name is the csv file name
        ===#
        tn = splitdir( fname )

        create_table_str = """
            create table if not exists $tn[2](
                $column_str   
            );
        """

        conn = open_connection()

        execute( conn, create_table_str )

        sql = """   
            SELECT
                *
            from $tn[2]
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

        copyin = LibPQ.CopyIn("COPY $tn[2] FROM STDIN (FORMAT CSV);", row_strings)

        execute(conn, copyin)

        close_connection( conn )
    end
end