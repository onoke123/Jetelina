# 指定されたcsvファイルをDataFrameに読み込んで、その後DBに書き込む
# depreacted: 2022/7/20 file_controller/csvfile_controller.jlに移行

using CSV
using DataFrames
using SQLite
using Genie, Genie.Renderer, Genie.Renderer.Json

#== テストデータがjetelina配下にある場合、@__DIR__でカレントディレクトリを示せる
　　　文字列接続はjoin()又は、string()でやる
==#
#fname = join([@__DIR__,"testdata/test.csv"],"/")
csvfname = joinpath( "testdata", "test.csv" )
fname = string( joinpath( @__DIR__, csvfname ) )
println( "csv file: ", fname );

df = CSV.read( fname, DataFrame )

#　表示しているだけ
#println( df )
json( Dict( "Jetelina" => copy.( eachrow( df ))));

# csvfnameのsqlite DBファイルがresource/testdata直下に作成される
# 
#db = SQLite.DB( "test.db" )

# DataFrameのデータをSQLiteに書き込む
#SQLite.load!( df, db, "df" )