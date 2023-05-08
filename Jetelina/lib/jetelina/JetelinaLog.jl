module JetelinaLog

using Logging
using JetelinaReadConfig,JetelinaFiles

export writetoLogfile

function logfileOpen()
    logfile = getFileNameFromLogPath(JetelinaLogfile)
    #logfile = string(joinpath(@__DIR__, "log", JetelinaLogfile))

    if debugflg
        println("JetelinaLog.jl logfile: ", logfile)
    end
    try
        io = open(logfile, "a+")
        logger = SimpleLogger(io)
        return io, logger
    catch err
        println("JetelinaLog.logfileOpen(): "$err)
    end
end

function writetoLogfile(s)
    io, logger = logfileOpen()
    with_logger(logger) do
        @info s
    end

    closeLogfile(io)
end

function closeLogfile(io)
    flush(io)
    close(io)
end
end