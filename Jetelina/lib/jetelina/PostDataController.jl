module PostDataController

    using Genie, Genie.Requests
    using JetelinaReadConfig, JetelinaLog

    function get()
        item = postpayload( :item )
        @info "post: ", item
        if debugflg
            debugmsg = "post data: $item"
            writetoLogfile( debugmsg )
        end
    end
end