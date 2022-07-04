# 指定されたcsvファイルをDataFrameに読み込んで、その後DBに書き込む

using CSV
using DataFrames
using SQLite

#== テストデータがjetelina配下にある場合、@__DIR__でカレントディレクトリを示せる
　　　文字列接続はjoin()又は、string()でやる
==#
#fname = join([@__DIR__,"testdata/test.csv"],"/")
csvfname = joinpath( "testdata", "test.csv" )
fname = string( joinpath( @__DIR__, csvfname ) )
df = CSV.read( fname, DataFrame )

#　表示しているだけ
println( df )

# csvfnameのsqlite DBファイルがresource/testdata直下に作成される
# 
db = SQLite.DB( "test.db" )

# DataFrameのデータをSQLiteに書き込む
SQLite.load!( df, db, "df" )