module PostDataController

    using Genie, Genie.Requests

    function get()
        item = postpayload( :item )
        println( "post data: ", item )
    end
end