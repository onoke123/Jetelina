# read the csv file in order to confirm the structure of containing data
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

# SQLiteに書き込まれたデータを操作する
sql_select = "select * from df"
query = DBInterface.execute( db, sql_select ) 
DataFrame( query )
