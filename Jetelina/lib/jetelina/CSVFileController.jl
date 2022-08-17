# 指定されたcsvファイルをDataFrameに読み込んで、その後DBに書き込む

module CSVFileController

    using CSV
    using DataFrames
    using SQLite
    using Genie, Genie.Renderer, Genie.Renderer.Json
    using JetelinaReadConfig, JetelinaLog

    function read()
        #== テストデータがjetelina配下にある場合、@__DIR__でカレントディレクトリを示せる
        　　　文字列接続はjoin()又は、string()でやる
        ==#
        #fname = join([@__DIR__,"testdata/test.csv"],"/")
        csvfname = joinpath( "testdata", "test.csv" )
        #fname = string( joinpath( @__DIR__, csvfname ) )
        fname = string( joinpath( "c:\\Users","user","Jetelina","Jetelina","app","resources", csvfname ) );
        
        if debugflg
            debugmsg = "csv file: $fname"
            writetoLogfile( debugmsg )
        end

        df = CSV.read( fname, DataFrame )

        #　表示しているだけ
        #println( df )
        json( Dict( "Jetelina" => copy.( eachrow( df ))))
    end

    # csvfnameのsqlite DBファイルがresource/testdata直下に作成される
    # 
    #db = SQLite.DB( "test.db" )

    # DataFrameのデータをSQLiteに書き込む
    #SQLite.load!( df, db, "df" )
end