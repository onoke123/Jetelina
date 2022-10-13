# 指定されたcsvファイルをDataFrameに読み込んで、その後DBに書き込む

module CSVFileController

    using CSV
    using DataFrames
    using SQLite
    using Genie, Genie.Renderer, Genie.Renderer.Json
    using JetelinaReadConfig, JetelinaLog
    using ExeSql

    function read( csvfname::String, row::Int )
        #== テストデータがjetelina配下にある場合、@__DIR__でカレントディレクトリを示せる
        　　　文字列接続はjoin()又は、string()でやる
        ==#
        if debugflg
            debugmsg = "csv file: $csvfname"
            writetoLogfile( debugmsg )
        end

        df = CSV.read( csvfname, DataFrame, limit=row )

        #===
            ここでinserttoPostgre()を呼んで、成功したら第一行だけ
            返して表示する
        ===#

        #　表示しているだけ
        json( Dict( "Jetelina" => copy.( eachrow( df ))))

    end

    function inserttoPostgre( df )
#===
        str_connect = "dbname= "postgres" host=127.0.0.1 user=postgres password= port=5432"
        conn = LibPQ.Connection(str_connect)
        LibPQ.load!( df, db, "df" )
===#
    end

    function inserttoDB( csvf )
        csvfname = joinpath( "testdata", csvf )
        fname = string( joinpath( @__DIR__, csvfname ) )

        if debugflg
            debugmsg = "csv file: $fname"
            writetoLogfile( debugmsg )
        end

        df = CSV.read( fname, DataFrame )

        # csvfnameのsqlite DBファイルがJetelinaDBPathで指定されたパスに作成される
        db = SQLite.DB( JetelinaDBPath )

        # DataFrameのデータをSQLiteに書き込む
        SQLite.load!( df, db, "df" )

        #===
            DB作成後、一連のSQL文を作成する。
            SQL文はこのファイル内に作成
        ===#
    end
end