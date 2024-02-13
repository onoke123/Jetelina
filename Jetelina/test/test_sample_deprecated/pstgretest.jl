using CSV, LibPQ, DataFrames, IterTools, Tables

csvfname = string( "ftest.csv" )
fname = string( joinpath( @__DIR__, csvfname ) )
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
    ct = string( column_type[i] )
    if startswith( ct, "Int" ) 
        column_type_string[i] = "integer"
    elseif startswith( ct, "Float" )
        column_type_string[i] = "double precision"
    elseif startswith( ct, "String" )
        vc_n = SubString( ct, length("String")+1, length(ct) )
        column_type_string[i] = "varchar( $vc_n )"
    end

    global column_str = string( column_str," ", column_name[i]," ", column_type_string[i] )
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

DATABASE_USER = "postgres"
conn = LibPQ.Connection("""host = 'localhost' 
port = '5432'
user = 'postgres'
password = 'postgres'
sslmode = prefer dbname = 'postgres' """)

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

#===
row_strings = imap(eachrow(df)) do row
    "$(row[$column_name[1]]),$(row[colun_name[2]]),$(row[colun_name[3]]),$(row[colun_name[4]])\n"
    #"$(row[:id]),$(row[:name]),$(row[:sex]),$(row[:age])\n"
    #===
    if ismissing(row[:yes_nulls])
        "$(row[:no_nulls]),\n"
    else
        "$(row[:no_nulls]),$(row[:yes_nulls])\n"
    end
    ===#
end
===#

copyin = LibPQ.CopyIn("COPY ftest FROM STDIN (FORMAT CSV);", row_strings)

execute(conn, copyin)

close(conn)