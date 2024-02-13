# SQLiteにあるデータをselectする

using DataFrames
using SQLite

function select_data( db )
    # SQLiteに書き込まれたデータを操作する
    sql_select = "select * from df"
    query = DBInterface.execute( db, sql_select ) 

    #　このdfにselectデータがあるので、呼び出し元に返してやればよさそう
    return DataFrame( query )
end