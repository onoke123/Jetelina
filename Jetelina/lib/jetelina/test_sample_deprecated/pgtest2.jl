using LibPQ, DataFrames, Tables, Genie.Renderer.Json

DATABASE_USER = "postgres"
conn = LibPQ.Connection("""host = 'localhost' 
port = '5432'
user = 'postgres'
password = 'postgres'
sslmode = prefer dbname = 'postgres' """)

sql = """   
select
    *
from jetelina_table_manager
"""        
#df = DataFrame(columntable(LibPQ.execute(conn, sql)))  
df = DataFrame(execute(conn, sql))  

sql = """
select nextval('jetelina_id');
"""
sequence_number = columntable(execute( conn, sql ))
close( conn )

#===
@info "df:" df
@info "se :" sequence_number
@info "se n:" columntable(sequence_number)
===#

n = sequence_number[1][1]
@info "se n1:" n, typeof( n )
#@info "number is: " n[1], typeof( n[1] )

#===
@info "column_name 1:" LibPQ.column_name(sequence_number,1)
@info "column_types:" LibPQ.column_types(sequence_number)
@info "num_params:" LibPQ.num_params(sequence_number)
@info "PQValue:" LibPQ.PQValue(sequence_number,1,1)
===#

#@info "eachrow: " json(Dict( "Jetelina" => copy.( eachrow( sequence_number ))))

#t = split( columntable(sequence_number), "=" )

#@info "t: " t