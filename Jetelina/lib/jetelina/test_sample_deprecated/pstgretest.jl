using CSV, LibPQ, DataFrames, IterTools

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

if column_type[1] <:Int64  column_type_string[1] = "integer" end
if column_type[2] <:String3  column_type_string[2] = "varchar(3)" end
if column_type[3] <:String1  column_type_string[3] = "varchar(1)" end
if column_type[4] <:Int64  column_type_string[4] = "integer" end

column_str = string( column_name[1]," ", column_type_string[1]," ", "primary key,",
                     column_name[2]," ", column_type_string[2],",",
                     column_name[3]," ", column_type_string[3],",",
                     column_name[4]," ", column_type_string[4] )
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

#=== data insert not yet
row_strings = imap(eachrow(df)) do row
    if ismissing(row[:yes_nulls])
        "$(row[:no_nulls]),\n"
    else
        "$(row[:no_nulls]),$(row[:yes_nulls])\n"
    end
end

copyin = LibPQ.CopyIn("COPY libpqjl_test FROM STDIN (FORMAT CSV);", row_strings)

execute(conn, copyin)
===#

close(conn)