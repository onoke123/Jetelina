module JetelinaLog

    using Logging
    using JetelinaReadConfig

    export writetoLogfile

    function logfileOpen()
        logfile = string( joinpath( @__DIR__, "log", JetelinaLogfile ) )

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