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
function _update(param::String, var)

	this function is hopefully be private.
	change the parameter with 'var', then calling _fileupdate() to set it into a configuration file.

# Arguments
- `param::String`:  configuration parameter name. ex. debug
- `var`:  configuration parameter new data. ex. true, 'min', '1234'....
"""
function _update(param::String, var)
	if contains(param,"db type")
		prevparam = j_config.JC[param] 
		j_config.JC[param] = var
		_fileupdate(JC[param],prevparam,var)
	end
end

"""
function _fileupdate(param::String, prev,var)

	this function is hopefully be private.
	update a configuration file with ordered param and var.

# Arguments
- `param::String`:  configuration parameter name. ex. debug
- `prev`:  previous data. ex. false, 'a_min', '4321'....
- `var`:  new data. ex. true, 'min', '1234'....
"""
function _fileupdate(param::String, prev,var)
	configfile = JFiles.getFileNameFromConfigPath("JetelinaConfig.cnf")
	configfile_tmp = string(configfile,".tmp")
	try
		f = open(configfile,"r+")
		tf = open(configfile_tmp,"w")
		l = readlines(f)
		for i ∈ 1:length(l)
			if startswith(l[i],param)
				p = replace(l[i],prev => var, count=1)
			else
				p = l[i]
			end

			println(tf,p)
		end

		close(tf)
		close(f)

		mv(configfile_tmp,configfile, force=true)
	catch err
		@error "ConfigManager._fileupdate() error $param changes with $prev -> $var: $err"
	end
end

end
