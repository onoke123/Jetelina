# 既存のDBにあるデータを操作する
# これはSQLiteを対象としている

using DataFrames
using SQLite

function readdatafromdb()
    db = SQLite.DB( "test.csv" )
    return select_data( db )
end