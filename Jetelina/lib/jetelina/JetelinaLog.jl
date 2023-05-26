module JetelinaLog

using Logging, Dates
using JetelinaReadConfig,JetelinaFiles

export writetoLogfile

function logfileOpen()
    logfile = getFileNameFromLogPath(JetelinaLogfile)

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
    # 日付をつける
    ss = string(Dates.format(now(),"yyyy-mm-dd HH:MM:SS"), " ",s)

    io, logger = logfileOpen()
    with_logger(logger) do
        # loggerは以下を記録しているので@infoは消さないで
        @info ss
    end

    closeLogfile(io)
end

function closeLogfile(io)
    flush(io)
    close(io)
end
end