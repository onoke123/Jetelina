"""
module: ConfigManager

	read configuration parameters from Jetelina.cnf file
	then set them to global variables

	contain functions
		__init__()
"""

module ConfigManager
using Jetelina.JFiles, Jetelina.JMessage

JMessage.showModuleInCompiling(@__MODULE__)

export JC

#===
export JC["logfile"],# log file name
	JC["logfilesize"], # log file size
	JC["debug"],# debug configuration true/false
	JC["fileuploadpath"],# csv file upload path
	JC["sqllogfile"],# SQL log file name
	JC["sqllogfilesize"],# SQL log file size
	JC["logfile_rotation_open"],# log file rotation execute time 'from'
	JC["logfile_rotation_close"],# log file rotation execute time 'till'
	JC["tablecombinationfile"],# real sql execution test data in json form
	JC["sqllistfile"],# real sql list file name
	JC["sqlaccesscountfile"],# sql access count data file name
	JC["sqlperformancefile"],# sql execution speed data file name
	JC["tableapifile"],# file name for relation between talbe name and api no
	JC["experimentsqllistfile"],# sql list file for execution in test db
	JC["improvesuggestionfile"],# suggestion file name due to execute test db
	JC["file_column_apino"],# column title of sqllogfile/sqllistfile/experimentalsqllistfile
	JC["file_column_sql"],# column title of sqllogfile/sqllistfile/experimentalsqllistfile
	JC["file_column_subquery"],# column title of sqllogfile/sqllistfile/experimentalsqllistfile
	JC["file_column_max"],# column title of sqllogfile/sqllistfile/experimentalsqllistfile
	JC["file_column_min"],# column title of sqllogfile/sqllistfile/experimentalsqllistfile
	JC["file_column_mean"],# column title of sqllogfile/sqllistfile/experimentalsqllistfile
	JC["dbtype"],# type of database
	JC["pg_host"],# DB host name
	JC["pg_port"],# DB port number
	JC["pg_user"],# DB access user account
	JC["pg_password"],# DB access user password
	JC["pg_sslmode"],# DB access ssl mode (in PostgreSQL)
	JC["pg_dbname"],# DB database name
	JC["pg_testdbname"],# DB database for testing by analyzing
	JC["selectlimit"],# execution limit number of select sentence in test db
	JC["reading_max_lines"], # maxmum lines to read 'sqllogfile'
	JC["analyze_interval"] # sql analyze execute interval 
===#

"""
function __init__()

	auto start this when the server starting.
	this function calls _readConfig function.
"""
function __init__()
	@info "=======ConfigManager init=========="
	_readConfig()
end

"""
function _readConfig()

	this function is hopefully be private.
	read configuration parameters from JetelinaConfig.cnf file,
	then set them to the global variables.
"""
function _readConfig()
	configfile = JFiles.getFileNameFromConfigPath("JetelinaConfig.cnf")

	try
		f = open(configfile, "r")
		l = readlines(f)
		global JC = Dict{String,Any}()

		for i ∈ 1:length(l)
			if !startswith(l[i], "#") && 0<length(l[i])
				ret = _getSetting(l[i])
				if ret[2] == "true" || ret[2] == "false"
					JC[ret[1]] = parse(Bool,ret[2])
				else
					JC[ret[1]] = ret[2]
				end
#				JetelinaConfig[ret[1]] = ret[2]
#===
				if startswith(l[i], "logfile")
					# log file name
					global JetelinaLogfile = _getSetting(l[i])
				elseif startswith(l[i], "size_logfile")
					# log file size
					global JetelinaLogfileSize = _getSetting(l[i])
				elseif startswith(l[i], "debug")
					# debug configuration true/false
					global debugflg = parse(Bool, _getSetting(l[i]))
				elseif startswith(l[i], "fileuploadpath")
					# CSV file upload path
					global JetelinaFileUploadPath = _getSetting(l[i])
				elseif startswith(l[i], "sqllogfile")
					# SQL log file name
					global JetelinaSQLLogfile = _getSetting(l[i])
				elseif startswith(l[i], "size_sqllogfile")
					# SQL log file name
					global JetelinaSQLLogfileSize = _getSetting(l[i])
				elseif startswith(l[i], "time1_logfile_rotation")
					# log file rotation execute time 'from'
					global JetelinaLogRotationTimeF = _getSetting(l[i])
				elseif startswith(l[i], "time2_logfile_rotation")
					# log file rotation execute time 'till'
					global JetelinaLogRotationTimeT = _getSetting(l[i])
				elseif startswith(l[i], "tablecombinationfile")
					# real sql execution test data file name in json form
					global JetelinaTableCombiVsAccessRelation = _getSetting(l[i])
				elseif startswith(l[i], "sqllistfile")
					# real sql list file name
					global JetelinaSQLListfile = _getSetting(l[i])
				elseif startswith(l[i], "sqlaccesscountfile")
					# sql access count data file name
					global JetelinaSqlAccess = _getSetting(l[i])
				elseif startswith(l[i], "sqlperformancefile")
					# sql execution speed data file name
					global JetelinaSqlPerformancefile = _getSetting(l[i])
				elseif startswith(l[i], "tableapifile")
					# file name for relation between talbe name and api no
					global JetelinaTableApifile = _getSetting(l[i])
				elseif startswith(l[i], "experimentsqllistfile")
					# sql list file for execution in test db
					global JetelinaExperimentSqlList = _getSetting(l[i])
				elseif startswith(l[i], "improvesuggestionfile")
					# suggestion file name due to execute test db
					global JetelinaImprApis = _getSetting(l[i])
				elseif startswith(l[i], "file_column_apino")
					# column title of sqllogfile/sqllistfile/experimentalsqllistfile
					global JetelinaFileColumnApino = _getSetting(l[i])
				elseif startswith(l[i], "file_column_sql")
					# column title of sqllogfile/sqllistfile/experimentalsqllistfile
					global JetelinaFileColumnSql = _getSetting(l[i])
				elseif startswith(l[i], "file_column_subquery")
					# column title of sqllogfile/sqllistfile/experimentalsqllistfile
					global JetelinaFileColumnSubQuery = _getSetting(l[i])

				elseif startswith(l[i], "file_column_max")
					# column title of sqllogfile/sqllistfile/experimentalsqllistfile
					global JetelinaFileColumnMax = _getSetting(l[i])
				elseif startswith(l[i], "file_column_min")
					# column title of sqllogfile/sqllistfile/experimentalsqllistfile
					global JetelinaFileColumnMin = _getSetting(l[i])
				elseif startswith(l[i], "file_column_mean")
					# column title of sqllogfile/sqllistfile/experimentalsqllistfile
					global JetelinaFileColumnMean = _getSetting(l[i])
				elseif startswith(l[i], "dbtype")
					# type of database
					global JetelinaDBtype = _getSetting(l[i])
					if JetelinaDBtype == "postgresql"
						# for PostgreSQL
						_setPostgres(l, i + 1)
					elseif JetelinaDBtype == "mariadb"
						# for MariaDB
					elseif JetelinaDBtype == "oracle"
						# for Oracle
					end
				elseif startswith(l[i], "selectlimit")
					# execution limit number of select sentence in test db
					global JetelinaTestDBDataLimitNumber = _getSetting(l[i])
				elseif startswith(l[i], "reading_max_lines")
					# maxmum lines to read 'sqllogfile'
					global JetelinaReadingLogMaxLine = _getSetting(l[i])
				elseif startswith(l[i], "analyze_interval")
					global JC["analyze_interval"] = _getSetting(l[i])
				end
===#
			else
				# ignore as comment
			end
		end

		close(f)
	catch err
		@error "ConfigManager._readConfig() error: $err"
		return false
	end

	return true
end

"""
function _getSetting(s::String)

	this function is hopefully be private.
	get value from 's'. 's' is expected 'name=value' style.
	return trimed array.

# Arguments
- `s::String`:  configuration data in 'name=value'. ex. 'debug = true'
- return: trimed array [1]:NAME,[2]:value  ex. [1]:"DEBUG",[2]:"true"
"""
function _getSetting(s::String)
	t = split(s, "=")
	t[1] = strip(t[1])
	t[2] = strip(t[2])

	return t
end

"""
function _setPostgres(l::String, c::Integer)

	this function is hopefully be private.
	parses and gets then set PostgreSQL connection parameterss to the global variables.

	deprecated.

# Arguments
- `l::Vector{String}`: configuration file strings
- `c::Int64`: file line number 
"""
function _setPostgres(l::Vector{String}, c::Int64)
	for i ∈ c:length(l)
		if !startswith(l[i], "#")
			if startswith(l[i], "host")
				# DB host
				global JC["dbtype"] = _getSetting(l[i])
			elseif startswith(l[i], "port")
				# DB port
				global JetelinaDBport = parse(Int16, _getSetting(l[i]))
			elseif startswith(l[i], "user")
				# DB host 
				global JetelinaDBuser = _getSetting(l[i])
			elseif startswith(l[i], "password")
				# DB user password
				global JetelinaDBpassword = _getSetting(l[i])
			elseif startswith(l[i], "sslmode")
				# DB ssl mode 
				global JetelinaDBsslmode = _getSetting(l[i])
			elseif startswith(l[i], "dbname")
				# DB name
				global JetelinaDBname = _getSetting(l[i])
			elseif startswith(l[i], "testdbname")
				# analyze test DB name
				global JetelinaTestDBname = _getSetting(l[i])
			end
		end
	end
end
function update(param::String, var)
	@info "param = var is " param var
	if contains(param,"db type")
		prevparam = j_config.JC["dbtype"] 
		j_config.JC["dbtype"] = var
		_fileupdate(JC["dbtype"],prevparam,var)
	end
end

function _fileupdate(param::String, prev,var)
	configfile = JFiles.getFileNameFromConfigPath("JetelinaConfig.cnf")
	configfile_tmp = string(configfile,".1")
	try
		f = open(configfile,"r+")
		tf = open(configfile_tmp,"w")
		l = readlines(f)
		for i ∈ 1:length(l)
			if startswith(l[i],"dbname")
				@info "find dbname" l[i] prev var
				p = replace(l[i],prev => var, count=1)
				@info "later " l[i] p
			else
				p = l[i]
			end
			#@info i " -> " l[i]
			println(tf,p)
		end

		close(tf)
		close(f)

		mv(configfile_tmp,configfile, force=true)
	catch err
		@error "ChangeParams._fileupdate() error: $err"
	end
end
end
