"""
module: JetelinaFiles

Author: Ono keiji
Version: 1.0
Description:
    read and write to log file

functions
    writetoLogfile(s)  write 's' to log file. date format is "yyyy-mm-dd HH:MM:SS".'s' is available whatever type.
"""
module JetelinaLog

using Logging, Dates
using JetelinaReadConfig,JetelinaFiles

export writetoLogfile

"""
function _logfileOpen()

    this function is hopefully be private.
    open log file. the log file is defined in Jetelina config file.

# Arguments
- return::tuple: IOStream, Logging.SimpleLogger
"""
function _logfileOpen()
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
"""
function writetoLogfile(s)

    write 's' to log file. date format is "yyyy-mm-dd HH:MM:SS".'s' is available whatever type.

# Arguments
- `s`: data to write in log file. String/Integer... whatever
"""
function writetoLogfile(s)
    # put date
    ss = string(Dates.format(now(),"yyyy-mm-dd HH:MM:SS"), " ",s)

    io, logger = _logfileOpen()
    with_logger(logger) do
        # do not delete this @info
        @info ss
    end

    _closeLogfile(io)
end
"""
function _closeLogfile(io::IOStream)

    this function is hopefully be private.
    close log file after fushing memory,

# Arguments
- `io::IOStream`: IOStream    
"""
function _closeLogfile(io::IOStream)
    flush(io)
    close(io)
end

end