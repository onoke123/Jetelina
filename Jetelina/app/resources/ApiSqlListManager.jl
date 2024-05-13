"""
module: ApiSqlListManager

Author: Ono keiji

Description:
	manage JC["sqllistfile"] file.
	this file determines a corrensponding SQL sentence to API.

functions
	readSqlList2DataFrame() import registered SQL sentence list in JC["sqllistfile"] to DataFrame.this function set the sql list data in the global variable 'Df_JetelinaSqlList' as DataFrame object.
	writeTolist(sql::String, tablename_arr::Vector{String}) create api no and write it to JC["sqllistfile"] order by SQL sentence.
	deleteTableFromlist(tablename::Vector) delete tables name from JC["sqllistfile"] synchronized with dropping table.
	deleteApiFromList(apis:Vector) delete api by ordering from JC["sqllistfile"] file, then refresh the DataFrame.
"""
module ApiSqlListManager

using DataFrames, CSV
using Jetelina.JFiles, Jetelina.JMessage, Jetelina.JLog
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

export readSqlList2DataFrame, writeTolist, deleteTableFromlist

"""
function __init__()

	this is the initialize process for importing registered SQL sentence list in JC["sqllistfile"] to DataFrame.
"""
function __init__()
	readSqlList2DataFrame()
end
"""
function readSqlList2DataFrame()

	import registered SQL sentence list in JC["sqllistfile"] to DataFrame.
	this function set the sql list data in the global variable 'Df_JetelinaSqlList' as DataFrame object.

# Arguments
- return: Tuple: suceeded (true::Boolean, list of api/sql::DataFrames)
				 failed   (false::Boolean, nothing)

"""
function readSqlList2DataFrame()
	sqlFile = JFiles.getFileNameFromConfigPath(j_config.JC["sqllistfile"])
	if isfile(sqlFile)
		df = CSV.read(sqlFile, DataFrame)
		if j_config.JC["debug"]
			@info "ApiSqlListManager.readSqlList2DataFrame() sql list in DataFrame: ", df
		end

		return true, df
	end

	return false, nothing
end
"""
function writeTolist(sql::String, tablename_arr::Vector{String}, seq_no::Integer)

	create api no and write it to JC["sqllistfile"] order by SQL sentence.
	
# Arguments
- `sql::String`: sql sentence
- `subquery::String`: sub query sentence
- `tablename_arr::Vector{String}`: table name list that are used in 'sql'
- `seq_no::Integer`: number of jetelian_sql_sequence
- return: Tuple: suceeded (true::Boolean, api number name::String)
				 failed   (false::Boolean, nothing)
"""
function writeTolist(sql::String, subquery::String, tablename_arr::Vector{String}, seq_no::Integer)
	sqlFile = JFiles.getFileNameFromConfigPath(j_config.JC["sqllistfile"])
	tableapiFile = JFiles.getFileNameFromConfigPath(j_config.JC["tableapifile"])

	suffix = string()

	if startswith(sql, "insert")
		suffix = "ji"
	elseif startswith(sql, "update") && contains(sql, "jetelina_delete_flg=1")
		suffix = "jd"
	elseif startswith(sql, "update")
		suffix = "ju"
	elseif startswith(sql, "select")
		suffix = "js"
		#        elseif startswith(sql, "delete")
		#            suffix = "jd"
	end

	sql = strip(sql)
	sqlsentence = """$suffix$seq_no,\"$sql\",\"$subquery\""""

	# write the sql to the file
	thefirstflg = true
	if !isfile(sqlFile)
		thefirstflg = false
	end

	try
		open(sqlFile, "a") do f
			if !thefirstflg
				println(f, string(j_config.JC["file_column_apino"], ',', j_config.JC["file_column_sql"], ',', j_config.JC["file_column_subquery"]))
			end

			println(f, sqlsentence)
		end
	catch err
		JLog.writetoLogfile("ApiSqlListManager.writeTolist() error: $err")
		return false, nothing
	end

	# write the relation between tables and api to the file
	try
		open(tableapiFile, "a") do ff
			println(ff, string(suffix, seq_no, ":", join(tablename_arr, ",")))
		end
	catch err
		JLog.writetoLogfile("ApiSqlListManager.writeTolist() error: $err")
		return false, nothing
	end

	# update DataFrame
	readSqlList2DataFrame()

	return true, string(suffix, seq_no)
end
"""
function deleteTableFromlist(tablename::Vector)

	delete table name from JC["sqllistfile"] synchronized with dropping table.

# Arguments
- `tablename::Vector`: target tables name
- return: boolean: true -> all done ,  false -> something failed
"""
function deleteTableFromlist(tablename::Vector)
	sqlFile = JFiles.getFileNameFromConfigPath(j_config.JC["sqllistfile"])
	tableapiFile = JFiles.getFileNameFromConfigPath(j_config.JC["tableapifile"])
	sqlTmpFile = string(sqlFile, ".tmp")
	tableapiTmpFile = string(tableapiFile, ",tmp")

	targetapi = []

	# take the backup file
	JFiles.fileBackup(tableapiFile)
	JFiles.fileBackup(sqlFile)

	try
		open(tableapiTmpFile, "w") do ttaf
			open(tableapiFile, "r") do taf
				# Tips: delete line feed by 'keep=false', then do println()
				for ss in eachline(taf, keep = false)
					if contains(ss, ':')
						p = split(ss, ":") # api_name:table,table,....
						tmparr = split(p[2], ',')
						for i in eachindex(tablename)
							if tablename[i] ∈ tmparr
								push!(targetapi, p[1]) # ["js1","ji2,.....]
							else
								# remain others in the file
								println(ttaf, ss)
							end
						end
					end
				end
			end
		end
	catch err
		JLog.writetoLogfile("ApiSqlListManager.deleteTableFromlist() error: $err")
		return false
	end

	# remain SQL sentence not include in the target api
	try
		open(sqlTmpFile, "w") do tf
			open(sqlFile, "r") do f
				for ss in eachline(f, keep = false)
					p = split(ss, "\"") # js1,"select..."
					if rstrip(p[1], ',') ∉ targetapi
						# write out sql that does not contain the target table
						println(tf, ss)
					else
					end
				end
			end
		end
	catch err
		JLog.writetoLogfile("ApiSqlListManager.deleteTableFromlist() error: $err")
		return false
	end

	# change the file name
	mv(sqlTmpFile, sqlFile, force = true)
	mv(tableapiTmpFile, tableapiFile, force = true)

	# update DataFrame
	readSqlList2DataFrame()

	return true
end
"""
function deleteApiFromList(apis:Vector)

	delete api by ordering from JC["sqllistfile"] file, then refresh the DataFrame.
	
# Arguments
- `tablename::Vector`: target tables name
- return: boolean: true -> all done ,  false -> something failed
"""
function deleteApiFromList(apis::Vector)
	#===
		Tips:
			apis is Array. ex. apino:["js100","js102"]
			insert(ji*),update(ju*),delete(jd*) api are forbidden to delete.
			only select(js*) is able to be rejected from api list.
	===#
	for a in apis
		if (!startswith(a, "js"))
			return false
		end
	end

	apiFile = JFiles.getFileNameFromConfigPath(j_config.JC["sqllistfile"])
	tableapiFile = JFiles.getFileNameFromConfigPath(j_config.JC["tableapifile"])
	apiFile_tmp = string(apiFile, ".tmp")
	tableapiTmpFile = string(tableapiFile, ",tmp")

	# take the backup file
	JFiles.fileBackup(tableapiFile)
	JFiles.fileBackup(apiFile)

	try
		open(apiFile_tmp, "w") do tio
			open(apiFile, "r") do io
				for ss in eachline(io, keep = false)
					p = split(ss, ",")
					if p[1] ∉ apis
						# remain others in the file
						println(tio, ss)
					end
				end
			end
		end
	catch err
		JLog.writetoLogfile("ApiSqlListManager.deleteApiFromList() error: $err")
		return false
	end

	try
		open(tableapiTmpFile, "w") do ttaf
			open(tableapiFile, "r") do taf
				# Tips: delete line feed by 'keep=false', then do println()
				for ss in eachline(taf, keep = false)
					for i in eachindex(apis)
						if !startswith(ss,apis[i])
							# leave it in the file
							println(ttaf, ss)
						end
					end
				end
			end
		end
	catch err
		JLog.writetoLogfile("ApiSqlListManager.deleteApiFromlist() error: $err")
		return false
	end

	# change the file name.
	mv(apiFile_tmp, apiFile, force = true)
	mv(tableapiTmpFile, tableapiFile, force = true)

	# update DataFrame
	readSqlList2DataFrame()

	return true
end

end
