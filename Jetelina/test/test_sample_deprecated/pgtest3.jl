using LibPQ, DataFrames, Tables, Genie.Renderer.Json

DATABASE_USER = "postgres"
conn = LibPQ.Connection("""host = 'localhost' 
port = '5432'
user = 'postgres'
password = 'postgres'
sslmode = prefer dbname = 'postgres' """)

sql = """   
create table if not exists dummytable(
    name varchar(10)
);
"""        
#df = DataFrame(columntable(LibPQ.execute(conn, sql)))  
ret = execute(conn, sql)  
ret2 = LibPQ.handle_result(ret)
#@info "ret:" LibPQ.column_types(ret) 

table_str = "select tablename from pg_tables where schemaname='public'"
df = DataFrame(columntable(LibPQ.execute(conn, table_str)))  
@info df

@info "filger:" DataFrames.filter!( row-> row.tablename == "ftest10",df )
@info "isempty: " isempty(df)