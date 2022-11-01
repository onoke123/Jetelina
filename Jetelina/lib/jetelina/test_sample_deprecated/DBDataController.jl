module DBDataController

    using DataFrames, Genie, Genie.Renderer, Genie.Renderer.Json, SQLite
    using JetelinaLog, JetelinaReadConfig
    using ExeSql

    function getalldbdata()
        #json( Dict( "alldata" => "df" => copy.( eachrow( readdatafromdb() ))))
        json( Dict( "Jetelina" => copy.( eachrow( readdatafromdb() ))))
    end

    function readdatafromdb()
        dbfile = JetelinaDBPath
        
        if debugflg
            dbgmsg = "dbfile: $dbfile" 
            writetoLogfile( dbgmsg )
        end

        db = SQLite.DB( dbfile )
        return select_data( db )
    end

    function select_data( db )
        # SQLiteに書き込まれたデータを操作する
        # select_tbl1()はExeSql.jlでexportされていないから
        sql_select = ExeSql.select_tbl1()
        query = DBInterface.execute( db, sql_select ) 

        #　このdfにselectデータがあるので、呼び出し元に返してやればよさそう
        return DataFrame( query )
    end

end