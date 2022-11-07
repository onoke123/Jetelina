using LibPQ, DataFrames, Tables

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
df = DataFrame(LibPQ.execute(conn, sql))  
close( conn )

@info "df:" df
