module PostDataController

    using Genie, Genie.Requests,Genie.Renderer.Json
    using DBDataController
    using JetelinaReadConfig, JetelinaLog

    function get()
        item_d = rawpayload()
        @info "post1: " item_d
#===

        item = postpayload()["item"]
        @info "post2: " item

        item = jsonpayload()
        @info "post3: " item
===#
        item_d = jsonpayload()["item"]
        @info "post4: " jsonpayload()["item"]
#===#
        item_d = jsonpayload("item")
        @info "post5: " item_d

        @show """this is the data $item_d"""
#===
        item = jsonpayload( :item )
        @info "post6: " item
===#
#===
        if debugflg
            debugmsg = "post data: $item"
            writetoLogfile( debugmsg )
        end
===#
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