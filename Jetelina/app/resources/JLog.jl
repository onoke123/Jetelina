"""
module: JLog

Author: Ono keiji
Version: 1.0
Description:
	read and write to log file

functions
	writetoLogfile(s)  write 's' to log file. date format is "yyyy-mm-dd HH:MM:SS".'s' is available whatever type.
	writetoSQLLogfile(apino::String, sql::String)  write executed sql with its apino to SQL log file. date format is "yyyy-mm-dd HH:MM:SS".
"""
module JLog

using Logging, Dates
using Jetelina.JFiles, Jetelina.JMessage

JMessage.showModuleInCompiling(@__MODULE__)

include("ReadConfig.jl")

export writetoLogfile, writetoSQLLogfile

const j_config = ReadConfig

"""
function _logfileOpen()

	this function is hopefully be private.
	open log file. the log file is defined in Jetelina config file.

# Arguments
- return::tuple (IOStream, Logging.SimpleLogger)
"""
function _logfileOpen()
	logfile = JFiles.getFileNameFromLogPath(j_config.JetelinaLogfile)
	logfilemaxsize = parse(Int, j_config.JetelinaLogfileSize)

	try
		if ispath(logfile)
			logfilemaxsize = logfilemaxsize*1000000 # transfer to MB
			if logfilemaxsize < filesize(logfile)
				# file rotation
				_fileRotation(logfile)
			end
		end

		io = open(logfile, "a+")
		logger = SimpleLogger(io)
		return io, logger
	catch err
		println("JLog._logfileOpen(): $err")
	end
end
"""
function writetoLogfile(s)

	write 's' to log file. date format is "yyyy-mm-dd HH:MM:SS".'s' is available whatever type.
	in this function, trying to use Logging.with_logger()

# Arguments
- `s`: data to write in log file. String/Integer... whatever
"""
function writetoLogfile(s)
	# put date
	ss = string(Dates.format(now(), "yyyy-mm-dd HH:MM:SS"), " ", s)

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

"""
function writetoSQLLogfile(apino::String, sql::String)

	write executed sql with its apino to SQL log file. date format is "yyyy-mm-dd HH:MM:SS".
	in this function, trying to be simple file accessing, not use Logging module

# Arguments
- `apino::String`: apino ex. ji101
- `sql::String`  : SQL sentence. ex. select aa,bb from table
"""
function writetoSQLLogfile(apino, sql)
	#==
		Tips:
			csv format is requested by SQLAnalyzer.
			ref: SQLAnalyzer.createAnalyzedJsonFile()
	===#
	log_str = string(Dates.format(now(), "yyyy-mm-dd HH:MM:SS"), ",", apino, ",\"", sql, "\"")
	sqllogfile = JFiles.getFileNameFromLogPath(j_config.JetelinaSQLLogfile)
	sqlfilemaxsize = parse(Int, sqlfilemaxsize)

	try
		if ispath(sqllogfile)
			sqlfilemaxsize = sqlfilemaxsize*1000000 # transfer to MB
			if sqlfilemaxsize < filesize(sqllogfile)
				# file rotation
				_fileRotation(sqllogfile)
			end
		end

		open(sqllogfile, "a+") do f
			println(f, log_str)
		end
	catch err
		writetoLogfile("JLog.writeToSQLLogfile() error: $err")
		return
	end
end
"""
function _fileRotation(f::String)

	"f" file move to "f.yyyy-mm-dd..." file.

# Arguments
- `f::String`: file name
"""
function _fileRotation(f::String)
	b = string(f,".",Dates.format(now(), "yyyy-mm-dd-HH:MM"))
	mv(f,b)
end
end
