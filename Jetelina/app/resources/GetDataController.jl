"""
module: GetDataController

Author: Ono keiji
Version: 1.0
Description:
	get i/f of ajax

functions
	getTableList() calling DBDataController.getTableList() with json mode. the return is json form naturally.
	getSqlAccessData() get JC["sqlaccesscountfile"] data file name. this file  contains access cound data in each sql due to sql.txt log file.
	getTableCombiVsAccessRelationData()  get JC["tablecombinationfile"] data file name. this file is analyzed data for table combination.
	getPerformanceRealData()  get JC["sqlperformancefile"] data file name. this file is analyzed data for real sql execution speed.
	getPerformanceTestData()  get JC["sqlperformancefile"] data file name but it is '.test' suffix. this file is analyzed data for sql execution speed on test db.
	checkExistImproveApiFile()  get JC["improvesuggestionfile"] data file name. this file contains an improving suggestion data of a target api. 
	getApiList()  get registering api list in json style.api list is refered in Df_JetelinaSqlList.
"""
module GetDataController

using Genie, Genie.Requests, Genie.Renderer.Json
using Jetelina.JFiles, Jetelina.ApiSqlListManager, Jetelina.DBDataController, Jetelina.JMessage
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

export getTableList, getTableCombiVsAccessRelationData, getPerformanceRealData, getPerformanceTestData, checkExistImproveApiFile, getApiList

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
	if ApiSqlListManager.readSqlList2DataFrame()[1]
		Df_JetelinaSqlList = ApiSqlListManager.readSqlList2DataFrame()[2]
		return json(Dict("result" => true, "Jetelina" => copy.(eachrow(Df_JetelinaSqlList))))
	else
		# not found SQL list
		return false
	end
end
end
