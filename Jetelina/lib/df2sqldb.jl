using DataFrames
using SQLite

function df2sqldb( df, db )
#    dbname = "test.db"
#    db = SQLite.DB( dbname )
    SQLite.load!( df, db, "df" )
#    SQLite.columns( db, "df" )

#    sql_select = "select * from df"
#    query = DBInterface.execute( db, sql_select ) 
#    DataFrame( query )
end