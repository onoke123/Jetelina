module PgDBController

    using CSV, LibPQ, DataFrames, IterTools, Tables
    using PgDataTypeList

    #===
    Data Base Connection
    ===#
    function open_connection()
        DATABASE_USER = "postgres"
        conn = LibPQ.Connection("""host = 'localhost' 
            port = '5432'
            user = 'postgres'
            password = 'postgres'
            sslmode = prefer dbname = 'postgres' """)    
    end

    #===
        Data Base connection close
    ===#
    function close_connection( conn )
        close( conn )
    end

    #===
        create table & data insert to DB from reading csv file
    ===#
    function dataInsertFromCSV( fname )
        @info "csv file: $fname"

        df = CSV.read( fname, DataFrame )
        @info df

        column_name = names(df)
        @info column_name

        column_type = eltype.(eachcol(df))
        @info column_type

        @info column_name[1], column_type[1], size(column_name)

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

        @info column_str

        create_table_str = """
            create table if not exists ftest(
                $column_str   
            );
        """

        conn = open_connection()

        execute( conn, create_table_str )

        sql = """   
            SELECT
                *
            from ftest
            LIMIT 1
            """        
        df0 = DataFrame(columntable(LibPQ.execute(conn, sql)))  
        cols = map(x -> x, names(df0))
        select!(df, cols)
        #select(df, cols)

        # create rows (maybe "," are not the best choice)
        row_strings = imap(eachrow(df)) do row
            join((ismissing(x) ? "null" : x for x in row), ",")*"\n"
        end

        copyin = LibPQ.CopyIn("COPY ftest FROM STDIN (FORMAT CSV);", row_strings)

        execute(conn, copyin)

        close_connection( conn )
    end
end