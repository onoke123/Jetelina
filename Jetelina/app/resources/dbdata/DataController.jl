module DataController

using DataFrames, Genie, Genie.Renderer, Genie.Renderer.Json, SQLite
#using RowDBAccess



function getalldata()
    #writetoLogfile( "test log")

    json( Dict( "alldata" => "columns" => copy.( eachrow( readdatafromdb() ))))
end

function readdatafromdb()
    dbfile = string( joinpath( "lib", "test.csv" ) )
    db = SQLite.DB( dbfile )
    return select_data( db )
end

function select_data( db )
    # SQLiteに書き込まれたデータを操作する
    sql_select = "select * from df"
    query = DBInterface.execute( db, sql_select ) 

    #　このdfにselectデータがあるので、呼び出し元に返してやればよさそう
    return DataFrame( query )
end

end