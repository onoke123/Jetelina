# 指定されたcsvファイルをDataFrameに読み込んで、その後DBに書き込む

using CSV
using DataFrames

#== テストデータがjetelina配下にある場合、@__DIR__でカレントディレクトリを示せる
　　　文字列接続はjoin()又は、string()でやる
==#
#fname = join([@__DIR__,"testdata/test.csv"],"/")
csvfname = "test.csv"
fname = string( @__DIR__,"/","testdata/",csvfname )
df = CSV.read( fname, DataFrame )

#　今はただ表示しているだけの関数
show_df( df )

# csvfnameのsqlite DBファイルがlib直下に作成される
db = SQLite.DB( csvfname )

# DataFrameのデータをSQLiteに書き込む
df2sqldb( df, db )

