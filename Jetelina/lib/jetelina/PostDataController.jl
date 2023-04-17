module PostDataController

    using Genie, Genie.Requests,Genie.Renderer.Json
    using DBDataController
    using JetelinaReadConfig, JetelinaLog, JetelinaReadSqlList

    function postDataAcquire()
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

            t = split( item_d[i], "." )
            t1 = strip( t[1] )
            t2 = strip( t[2] )
            if 0<length(selectSql)
                selectSql = """$selectSql, $t1.$t2"""
            else
                selectSql = """$t1.$t2"""
            end

            if( 0<length(tableName) )
                if( !contains(tableName, t1 ) )
                    tableName = """$tableName,$t1 as $t1"""
                end
            else
                tableName = """$t1 as $t1"""
            end

            @info "t1, t2: ", t1, t2
        end

        # get the sequence name then create the sql sentence
        seq_no = DBDataController.getSequenceNumber(1)
        selectSql = """$seq_no,\"select $selectSql from $tableName\"\n"""
        @info "sql: ", selectSql

        # write the sql to the file
        sqlFile = string( joinpath( @__DIR__, "config", "JetelinaSqlList" ))
        f = open( sqlFile, "a" )
        if isfile( sqlFile )
            write(f, selectSql)
        else
            write(f,"no,sql")
            write(f,selectSql)
        end
        close(f)

        JetelinaReadSqlList.readSqlList2DataFrame()
    end

    function getColumns()
        tableName = jsonpayload( "tablename" )
        @info "getColumns: " tableName
        DBDataController.getColumns( tableName )
    end

#==
    tableを指定してそれに関連するapiを返す関数。
    なにかに使いそうなのでコメントアウトして残しておく。
    function getApiList()
        tableName = jsonpayload( "tablename" )
        @info "getApiList: " tableName
        target = contains( tableName )
        #===
          DataFrame Df_JetelinaSqlListから、指定したtableNameが含まれる"sql"カラムを
          filter()で絞り込んでいる。
          次は絞り込みをVectorにしてJson化したい。
          Caution: filter!()は使わない。なぜならDf_Jete...はそのままにしておくから。
        ===#
        sql_list = filter( :sql => target, Df_JetelinaSqlList )
        @info "sql_list: " sql_list
        ret = json( Dict( "Jetelina" => copy.( eachrow( sql_list ))))
        @info "sql list ret: " ret
        return ret
    end
==#
    #==
        APIのリストを返す。
        単純にDf_JetelinaSqlListをJSON形式にして返す。
    ==#
    function getApiList()
        return json( Dict( "Jetelina" => copy.( eachrow( Df_JetelinaSqlList ))))
    end

#===
    function _checkTable( s ){
        p = split( s, "from" )
        p[2].chop
    }
===#
    function deleteTable()
        tableName = jsonpayload( "tablename" )
        @info "dropTable: " tableName
        DBDataController.dropTable( tableName )
    end

    function login()
        userName = jsonpayload( "username" )
        @info "login: " userName
        DBDataController.getUserAccount( userName )
#        if userName == "keiji"
#        return json(Dict("name" => "keiji"))
    end
end