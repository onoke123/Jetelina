using Genie, Genie.Renderer, Genie.Renderer.Json
using LibPQ, DataFrames, IterTools, Tables


DATABASE_USER = "postgres"
conn = LibPQ.Connection("""host = 'localhost' 
port = '5432'
user = 'postgres'
password = 'postgres'
sslmode = prefer dbname = 'postgres' """)

table_str = "select tablename from pg_tables where schemaname='public'"
#table_str = "select id,name from ftest"
#result = execute(conn, table_str)
#@info "result:", result

#data = columntable( result )
#@info  "data:",data
df0 = DataFrame(columntable(LibPQ.execute(conn, table_str)))  
#cols = map(x -> x, names(df0))
#select!(df, cols)
@info df0

@info json( Dict( "Jetelina" => copy.( eachrow( df0 ))))

close(conn)