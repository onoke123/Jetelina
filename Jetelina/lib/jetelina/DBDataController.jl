module DBDataController

    using DataFrames, Genie, Genie.Renderer, Genie.Renderer.Json, SQLite
    using JetelinaLog

    function getalldbdata()
        JetelinaLog.writetoLogfile( "test 8/5 log")

        #json( Dict( "alldata" => "df" => copy.( eachrow( readdatafromdb() ))))
        json( Dict( "Jetelina" => copy.( eachrow( readdatafromdb() ))))
    end

    function readdatafromdb()
        dbfile = string( joinpath( "c:\\Users","user","Jetelina","Jetelina","app","resources", "test.db" ) );
        #JetelinaLog.writetoLogfile(" dbfile: " * dbfile )
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