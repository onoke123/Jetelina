using DataFrames, Genie, Genie.Renderer, Genie.Renderer.Json, SQLite

function getalldata()
    JetelinaLog.writetoLogfile( "test log")
    #json( Dict( "alldata" => readdatafromdb() ))

    json( Dict( "alldata" => "columns" => copy.( eachrow( readdatafromdb() ))))
end

function readdatafromdb()
    db = SQLite.DB( "test.db" )
    return select_data( db )
end

function select_data( db )
    # SQLiteに書き込まれたデータを操作する
    sql_select = "select * from df"
    query = DBInterface.execute( db, sql_select ) 

    #　このdfにselectデータがあるので、呼び出し元に返してやればよさそう
    return DataFrame( query )
end
