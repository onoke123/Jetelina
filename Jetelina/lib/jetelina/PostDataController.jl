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
        @info "post: " item_d


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