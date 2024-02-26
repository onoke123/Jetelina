"""
	module: LogFileRotator

	Author: Ono keiji
	Version: 1.0
	Description:
        This module is for rotating Jetelina log files.
	
	functions
			main() wrap function for executing _exectuterotating() that is the real file rotating function.
			stoprotating() manual stopper for log file totating repeat.
"""
module LogFileRotator

using Dates
using Jetelina.JMessage, Jetelina.JFiles, Jetelina.JLog 

JMessage.showModuleInCompiling(@__MODULE__)

include("ReadConfig.jl")

const j_config = ReadConfig
const interval::Integer = 3600 # 1hr = 60*60
procflg = Ref(true) # rotation process progressable -> true, stop/error -> false

"""
function main()

	wrap function for executing _exectuterotating() that is the real file rotating function.
"""
function main()
	ft = j_config.JetelinaLogRotationTimeF
	tt = j_config.JetelinaLogRotationTimeT
		 
	task = @async while procflg[]
		if ft < Dates.format(now(),"HH:MM") < tt
			_exectuterotating()
			JLog.writetoLogfile(string("LogFileRotator.main() rotated log file in : ",Dates.format(now(), "yyyy-mm-dd-HH:MM")))
		end

		sleep(interval)
	end
end
"""
function _exectuterotating()

	execute log and sql log files
"""
function _exectuterotating()
	logfile = JFiles.getFileNameFromLogPath(j_config.JetelinaLogfile)
	sqllogfile = JFiles.getFileNameFromLogPath(j_config.JetelinaSQLLogfile)
	_fileRotation(logfile)
	_fileRotation(sqllogfile)
end
"""
function _fileRotation(f::String)

	"f" file move to "f.yyyy-mm-dd..." file.

# Arguments
- `f::String`: file name
"""
function _fileRotation(f::String)
	b = string(f,".",Dates.format(now(), "yyyy-mm-dd-HH:MM"))
	if ispath(f)
		mv(f,b)
	end
end
"""
function stoprotating()

	manual stopper for log file totating repeat
"""
function stoprotating()
	procflg[] = false
end

end