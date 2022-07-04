module JetelinaLog

    using Logging

    function logfileOpen()
        io = open("log.txt", "a+")
        logger = SimpleLogger( io )
        return io, logger
    end

    function writetoLogfile( s )
        io, logger = logfileOpen()
        with_logger( logger ) do 
            @info s
        end

        closeLogfile( io )
    end

    function closeLogfile( io )
        flush( io )
        close( io )
    end
end