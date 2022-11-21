module PostDataController

    using Genie, Genie.Requests,Genie.Renderer.Json
    using DBDataController
    using JetelinaReadConfig, JetelinaLog

    function get()
        #==
          dashboard.htmlからのcolumn post dataは以下のjson形式で来る
             { 'item':'["<table name>:<column name>","<table name>:<column name>",...]' }
          で来る。これをjsonpayload("item")で受けると
             item_d -> ["<table name>:<column name1>","<table name>:<column name2>",...]
          になるので、後は配列処理で
             [1] -> <table name>:<column name1>
          とするが、さらにtable名とカラム名に分けるので ':'　で文字分解して
             table name  -> <table name>
             column name -> <column name1>
          としてsql文作成に使用する
        ==#
        item_d = jsonpayload("item")
        @info "post: " item_d, size(item_d)
        #===
            なぜsize(..)[1]かというと、上の@info出力でみるとsize(item_d)->(n,) とTupleになっていて
            最初の"n"が配列の長さなので、ってこと
        ===#
        selectSql = ""
        tableName = ""
        for i = 1:size(item_d)[1]
            @info "data $i->", item_d[i]

            t = split( item_d[i], ":" )
            t1 = strip( t[1] )
            t2 = strip( t[2] )
            if 0<length(selectSql)
                selectSql = """$selectSql, $t2"""
            else
                selectSql = t2
            end

            tableName = t1

            @info "t1, t2: ", t1, t2
        end

        # get the sequence name then create the sql sentence
        seq_no = DBDataController.getSequenceNumber(1)
        selectSql = """$seq_no:select $selectSql from $tableName\n"""
        @info "sql: ", selectSql

        # write the sql to the file
        sqlFile = string( joinpath( @__DIR__, "config", "JetelinaSqlList" ))
        f = open( sqlFile, "a" )
        write(f, selectSql)
        close(f)
    end

    function getcolumns()
        tableName = jsonpayload( "tablename" )
        @info "getcolumns: " tableName
        DBDataController.getColumns( tableName )
    end

    function deleteTable()
        tableName = jsonpayload( "tablename" )
        @info "dropTable: " tableName
        DBDataController.dropTable( tableName )
    end

end