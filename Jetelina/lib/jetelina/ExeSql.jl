using JetelinaLog

module ExeSql

    function select_tbl1()
        tbl1_select_sql = "select * from df"

        return tbl1_select_sql
    end

    function table1_select()
        writetoLogfile( "table1 select" )

        tbl1_select_sql = "select * from df"

        return tbl1_select_sql
    end

end
