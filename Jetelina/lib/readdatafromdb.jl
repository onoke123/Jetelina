# 既存のDBにあるデータを操作する
# これはSQLiteを対象としている

using DataFrames
using SQLite

db = SQLite.DB( "test.csv" )
res = select_data( db )
println( DataFrame( res ) )
