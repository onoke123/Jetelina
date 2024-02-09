"""
module: GetDataController

Author: Ono keiji
Version: 1.0
Description:
	get i/f of ajax

functions
	getTableList() calling DBDataController.getTableList() with json mode. the return is json form naturally.
	getSqlAccessData() get JetelinaSqlAccess data file name. this file  contains access cound data in each sql due to sql.txt log file.
	getTableCombiVsAccessRelationData()  get JetelinaTableCombiVsAccessRelation data file name. this file is analyzed data for table combination.
	getPerformanceRealData()  get JetelinaSqlPerformancefile data file name. this file is analyzed data for real sql execution speed.
	getPerformanceTestData()  get JetelinaSqlPerformancefile data file name but it is '.test' suffix. this file is analyzed data for sql execution speed on test db.
	checkExistImproveApiFile()  get JetelinaImprApis data file name. this file contains an improving suggestion data of a target api. 
	getApiList()  get registering api list in json style.api list is refered in Df_JetelinaSqlList.
"""
module GetDataController
@info "GetDataController compiling..."
using Genie, Genie.Requests, Genie.Renderer.Json
using Jetelina.JFiles, Jetelina.ApiSqlListManager, Jetelina.DBDataController

include("ReadConfig.jl")

const j_config = ReadConfig

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

	get JetelinaSqlAccess data file name. this file  contains access numbers data in each sql due to sql.txt log file.

# Arguments
- return: JetelinaSqlAccess file name with its path
"""
function getSqlAccessData()
	f = JFiles.getFileNameFromLogPath(j_config.JetelinaSqlAccess)
	if isfile(f)
		return readchomp(f)
	else
		return false
	end
end
"""
function getTableCombiVsAccessRelationData()

	get JetelinaTableCombiVsAccessRelation data file name. this file is analyzed data for table combination.

# Arguments
- return: JetelinaTableCombiVsAccessRelation file name with its path
"""
function getTableCombiVsAccessRelationData()
	f = JFiles.getFileNameFromLogPath(j_config.JetelinaTableCombiVsAccessRelation)
	if isfile(f)
		return readchomp(f)
	else
		return false
	end
end
"""
function getPerformanceRealData()

	get JetelinaSqlPerformancefile data file name. this file is analyzed data for real sql execution speed.

# Arguments
- return: JetelinaSqlPerformancefile of json style with its path
"""
function getPerformanceRealData()
	f = JFiles.getFileNameFromLogPath(string(j_config.JetelinaSqlPerformancefile, ".json"))
	if isfile(f)
		return readchomp(f)
	else
		return false
	end
end
"""
function getPerformanceTestData()

	get JetelinaSqlPerformancefile data file name but it is '.test' suffix. this file is analyzed data for sql execution speed on test db.

# Arguments
- return: JetelinaSqlPerformancefile of json style with its path
"""
function getPerformanceTestData()
	f = JFiles.getFileNameFromLogPath(string(j_config.JetelinaSqlPerformancefile, ".test.json"))
	if isfile(f)
		return readchomp(f)
	else
		return false
	end
end
"""
function checkExistImproveApiFile()

	get JetelinaImprApis data file name. this file contains an improving suggestion data of a target api. 

# Arguments
- return: JetelinaImprApis file name with its path    
"""
function checkExistImproveApiFile()
	f = JFiles.getFileNameFromLogPath(j_config.JetelinaImprApis)
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
