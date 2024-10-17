"""
module: GetDataController

Author: Ono keiji

Description:
	get i/f of ajax

functions
	logout() logout procedure. update jetelina_user_table.logoutdate.
	getTableList() calling DBDataController.getTableList() with json mode. the return is json form naturally.
	getSqlAccessData() get JC["sqlaccesscountfile"] data file name. this file  contains access cound data in each sql due to sql.txt log file.
	getTableCombiVsAccessRelationData()  get JC["tablecombinationfile"] data file name. this file is analyzed data for table combination.
	getPerformanceRealData()  get JC["sqlperformancefile"] data file name. this file is analyzed data for real sql execution speed.
	getPerformanceTestData()  get JC["sqlperformancefile"] data file name but it is '.test' suffix. this file is analyzed data for sql execution speed on test db.
	checkExistImproveApiFile()  get JC["improvesuggestionfile"] data file name. this file contains an improving suggestion data of a target api. 
	getApiList()  get registering api list in json style.api list is refered in Df_JetelinaSqlList.
	getConfigHistory() get configuration change history in json style.
	getWorkingDBList() get db list that is working.
"""
module GetDataController

using Genie, Genie.Requests, Genie.Renderer.Json, DataFrames
using Jetelina.JFiles, Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.DBDataController, Jetelina.JMessage, Jetelina.JSession
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

export logout, getTableList, getTableCombiVsAccessRelationData, getPerformanceRealData, getPerformanceTestData, checkExistImproveApiFile, getApiList, getConfigHistory, getWorkingDBList

"""
function logout()

	logout procedure. update jetelina_user_table.logoutdate.
"""
function logout()
	uid = JSession.get()[2]
	key1 = "logoutdate"
	key2 = "last_dbtype"
	value = "now()"

	if !isnothing(uid)
		DBDataController.updateUserInfo(uid, key2, JSession.getDBType())
		ret = DBDataController.updateUserData(uid, key1, value)
	end

	# session data clear
	JSession.clear()

	return ret
end
"""
function getTableList()

	calling DBDataController.getTableList() with json mode.
	the return is json form naturally.
"""
function getTableList()
	DBDataController.getTableList("json")
end
"""
function getSqlAccessData()

	get JC["sqlaccesscountfile"] data file name. this file  contains access numbers data in each sql due to sql.txt log file.

# Arguments
- return: JC["sqlaccesscountfile"] file name with its path
"""
function getSqlAccessData()
	f = JFiles.getFileNameFromLogPath(j_config.JC["sqlaccesscountfile"])
	if isfile(f)
		return readchomp(f)
	else
		return false
	end
end
"""
function getTableCombiVsAccessRelationData()

	get JC["tablecombinationfile"] data file name. this file is analyzed data for table combination.

# Arguments
- return: JC["tablecombinationfile"] file name with its path
"""
function getTableCombiVsAccessRelationData()
	f = JFiles.getFileNameFromLogPath(j_config.JC["tablecombinationfile"])
	if isfile(f)
		return readchomp(f)
	else
		return false
	end
end
"""
function getPerformanceRealData()

	get JC["sqlperformancefile"] data file name. this file is analyzed data for real sql execution speed.

# Arguments
- return: JC["sqlperformancefile"] of json style with its path
"""
function getPerformanceRealData()
	f = JFiles.getFileNameFromLogPath(string(j_config.JC["sqlperformancefile"], ".json"))
	if isfile(f)
		return readchomp(f)
	else
		return false
	end
end
"""
function getPerformanceTestData()

	get JC["sqlperformancefile"] data file name but it is '.test' suffix. this file is analyzed data for sql execution speed on test db.

# Arguments
- return: JC["sqlperformancefile"] of json style with its path
"""
function getPerformanceTestData()
	f = JFiles.getFileNameFromLogPath(string(j_config.JC["sqlperformancefile"], ".test.json"))
	if isfile(f)
		return readchomp(f)
	else
		return false
	end
end
"""
function checkExistImproveApiFile()

	get JC["improvesuggestionfile"] data file name. this file contains an improving suggestion data of a target api. 

# Arguments
- return: JC["improvesuggestionfile"] file name with its path    
"""
function checkExistImproveApiFile()
	f = JFiles.getFileNameFromLogPath(j_config.JC["improvesuggestionfile"])
	if isfile(f)
		return readchomp(f)
	else
		return false
	end
end
"""
function getApiList()

	get registering api list in json style.
	api list is refered in Df_JetelinaSqlList.
"""
function getApiList()
	#===
		Tips:
			ApiSql...readSql...()[1] contains true/false.
			ApiSql...readSql...()[2] contains dataframe list if [] is true, in the case of false is nothing.
	===#
	if 0 < nrow(ApiSqlListManager.Df_JetelinaSqlList)
		return json(Dict("result" => true, "Jetelina" => copy.(eachrow(reverse(ApiSqlListManager.Df_JetelinaSqlList)))))
	else
		# not found SQL list
		return json(Dict("result" => false, "Jetelina" => "[{}]", "errmsg" => "Oops! there is no api list data"))
	end
end
"""
function getConfigHistory()

	get configuration change history in json style.
"""
function getConfigHistory()
	f = JFiles.getFileNameFromLogPath(j_config.JC["config_change_history_file"])

	if isfile(f)
		ret = "{\"Jetelina\":["

		try
			for line in Iterators.reverse(eachline(f))
					ret = string(ret,line,",")
			end

			ret = strip(ret,',')
			return string(ret,"],\"result\":true}")
		catch err
			@error "ConfigManager.getConfigHistory() error: $err"
			return false
		end
	else
		return false
	end
end
"""
function getWorkingDBList()
	
	get db list that is working.
"""
function getWorkingDBList()
	postgres = j_config.JC["pg_work"]
	mysql    = j_config.JC["my_work"]
	redis    = j_config.JC["redis_work"]
	df = DataFrame("postgres"=>postgres,"mysql"=>mysql,"redis"=>redis)
	return json(Dict("result" => true, "Jetelina" => copy.(eachrow(df))))
end
end