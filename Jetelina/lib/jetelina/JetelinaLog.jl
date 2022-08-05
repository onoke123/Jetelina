module JetelinaLog

    using Logging
    using JetelinaReadConfig

    function logfileOpen()
        logfile = JetelinaLogfile

        if debugflg
            println("JetelinaLog.jl logfile: ", logfile)
        end

        io = open( logfile, "a+")
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