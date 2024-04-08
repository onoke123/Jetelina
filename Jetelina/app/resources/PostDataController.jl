"""
module: PostDataController

Author: Ono keiji
Version: 1.0
Description:
	all controll for poting data from clients

functions
	getConfigData()	get a configuration parameter data ordered by posting data.
	handleApipostdata() execute ordered API by posting data.
	createApi()  create API and SQL select sentence from posting data.
	getColumns()  get ordered tables's columns with json style.ordered table name is posted as the name 'tablename' in jsonpayload().
	deleteTable()  delete table by ordering. this function calls DBDataController.dropTable(tableName), so 'delete' meaning is really 'drop'.ordered table name is posted as the name 'tablename' in jsonpayload().
	userRegist() register a new user
	login()  login procedure.user's login account is posted as the name 'username' in jsonpayload().
	getUserInfoKeys()  get "user_info" column key data.
	refUserAttribute() refer the user attribute after login().
	updateUserInfo() update user information data
	updateUserData() update user data
	updateUserLoginData() update user login data like logincount,logindate,.....
	deleteUserAccount() delete user account from jetelina_user_table
	deleteApi()  delete api by ordering from JC["sqllistfile"] file, then refresh the DataFrame.
	configParamUpdate()	update configuration parameter
"""
module PostDataController

using Genie, Genie.Requests, Genie.Renderer.Json
using Jetelina.JFiles, Jetelina.JLog, Jetelina.ApiSqlListManager, Jetelina.DBDataController, Jetelina.JMessage
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

export getConfigData, handleApipostdata, createApi, getColumns, deleteTable, userRegist, login, getUserInfoKeys, refUserAttribute, updateUserInfo,
	updateUserData, updateUserLoginData, deleteUserAccount, deleteApi, configParamUpdate


"""
function getConfigData()

	get a configuration parameter data ordered by posting data.

# Arguments
- return: json data including ordered a configuration if there were. ex. {"result":true,"logfile":"log.txt"}
"""
function getConfigData()
	d = jsonpayload("param")
	if !contains(d, "password")
		if !isnothing(j_config.JC[d])
			return json(Dict("result" => true, d => j_config.JC[d]))
		else
			return json(Dict("result" => false))
		end
	else
		# if "password" is required
		return json(Dict("result" => true, d => "keep it secret.(^^)v"))
	end
end

"""
function handleApipostdata()

	execute ordered API by posting data.

# Arguments
- return: insert/update/delete -> true/false
		  select               -> json format data
		  error                -> false
"""
function handleApipostdata()
	return DBDataController.executeApi(jsonpayload())
end
"""
function createApi()

	create API and SQL select sentence from posting data.

# Arguments
- return: this sql is already existing -> json {"resembled":true}
		  new sql then success to append it to  -> json {"apino":"<something no>"}
					   fail to append it to     -> false
"""
function createApi()
	mode = jsonpayload("mode")
	#===
		Tips:
			expect mode is "" or "pre".
			""->registration
			"pre"->api test
	===#
	if isnothing(mode) || length(mode) == 0
		mode = "ok"
	end

	return DBDataController.createApiSelectSentence(jsonpayload(), mode)
end
"""
function getColumns()

	get ordered tables's columns with json style.
	ordered table name is posted as the name 'tablename' in jsonpayload().
"""
function getColumns()
	ret = ""
	tableName = jsonpayload("tablename")
	if !isnothing(tableName)
		ret = DBDataController.getColumns(tableName)
	end

	return ret
end
"""
function deleteTable()

	delete table by ordering. this function calls DBDataController.dropTable(tableName), so 'delete' meaning is really 'drop'.
	ordered table name is posted as the name 'tablename' in jsonpayload().
"""
function deleteTable()
	ret = ""
	tableName::Vector = jsonpayload("tablename")
	if !isnothing(tableName)
		ret = DBDataController.dropTable(tableName)
	end

	return ret
end
"""
function userRegist()

	register a new user

# Arguments
- return::boolean: success->true  fail->false        
"""
function userRegist()
	ret = ""
	userName = jsonpayload("username")
	if !isnothing(userName)
		ret = DBDataController.userRegist(userName)
	end

	return ret
end
"""
function login()

	login procedure. just checking the existence here.
	user's login account is posted as the name 'username' in jsonpayload().
"""
function login()
	ret = ""
	userName = jsonpayload("username")
	if !isnothing(userName)
		ret = DBDataController.chkUserExistence(userName)
	end

	return ret
end
"""
function getUserInfoKeys()

	get "user_info" column key data.

# Arguments
- return: ture/false in json form
"""
function getUserInfoKeys()
	ret = ""
	uid = jsonpayload("uid")
	if !isnothing(uid)
		ret = DBDataController.getUserInfoKeys(uid)
	end

	return ret
end

"""
function refUserAttribute()

	refer the user attribute after login().
	the user is not autherized here yet.

# Arguments
- return: ture/false in json form
"""
function refUserAttribute()
	ret = ""
	uid = jsonpayload("uid")
	key = jsonpayload("key")
	val = jsonpayload("val")
	if !isnothing(uid) && !isnothing(key) && !isnothing(val)
		ret = DBDataController.refUserAttribute(uid, key, val)
	end

	return ret
end
"""
function updateUserInfo()

	update user information data

# Arguments
- return: ture/false in json form
"""
function updateUserInfo()
	ret = ""
	uid = jsonpayload("uid")
	key = jsonpayload("key")
	val = jsonpayload("val")
	if !isnothing(uid) && !isnothing(key) && !isnothing(val)
		ret = DBDataController.updateUserInfo(uid, key, val)
	end

	return ret
end
"""
function updateUserData()

	update user data
	this function can use for simple column form, I mean not for jsonb column.

# Arguments
- return: ture/false in json form
"""
function updateUserData()
	ret = ""
	uid = jsonpayload("uid")
	key = jsonpayload("key")
	val = jsonpayload("val")
	if !isnothing(uid) && !isnothing(key) && !isnothing(val)
		ret = DBDataController.updateUserData(uid, key, val)
	end

	return ret
end
"""
function updateUserLoginData()

	update user login data like logincount,logindate,.....

# Arguments
- return: ture/false in json form
"""
function updateUserLoginData()
	ret = ""
	uid = jsonpayload("uid")
	if !isnothing(uid)
		ret = DBDataController.updateUserLoginData(uid)
	end

	return ret
end
"""
function deleteUserAccount()

	delete user account from jetelina_user_table

# Arguments
- return: true/false in json form
"""
function deleteUserAccount()
	ret = ""
	uid = jsonpayload("uid")
	if !isnothing(uid)
		ret = DBDataController.deleteUserAccount(uid)
	end

	return ret
end
"""
function _addJetelinaWords()

	expected keeping a private func.
	this should not open to all users.
"""
function _addJetelinaWords()
	newwords = jsonpayload("sayjetelina")
	arr = jsonpayload("arr")

	# adding scenario
	#        scenarioFile = string( joinpath( "..","..","public","jetelina","js","scenario.js" ))
	scenarioFile = JFiles.getJsFileNameFromPublicPath("scenario.js")
	scenarioTmpFile = JFiles.getJsFileNameFromPublicPath("scenario.tmp")
	target_scenario = "scenario[\"$arr\"]"
	rewritestring = ""

	open(scenarioTmpFile, "w") do tf
		open(scenarioFile, "r") do f
			#===
				Tips:
					reject a new line char by keep=false,
					then do println()
			===#
			for ss in eachline(f, keep = false)
				if startswith(ss, target_scenario)
					# add the new word to there at here
					ss = ss[1:length(ss)-2] * ",\"$newwords\"];"
				end

				println(tf, ss)
			end
		end
	end

	#after all, return the name of scenarioTmpFile to scenarioFile
	mv(scenarioTmpFile, scenarioFile, force = true)

	return true
end
"""
function deleteApi()

	delete api by ordering from JC["sqllistfile"] file, then refresh the DataFrame.

# Arguments
- return: ture/false in json form	
"""
function deleteApi()
	apis::Vector = jsonpayload("apino")
	jmsg::String = string("compliment me!")
	retapis::String = join(apis,",") # ["a","b"] -> "a,b" oh ＼(^o^)／

	if( ApiSqlListManager.deleteApiFromList(apis) )
		ret = json(Dict("result" => true, "apiname" => "$retapis", "message from Jetelina" => jmsg))
	else
		ret = json(Dict("result" => false, "apiname" => "$retapis", "errmsg" => "Oh my, plz ref log file"))
	end
end
"""
function configParamUpdate()

	update configuration parameter

# Arguments
- return: ture/false in json form
"""
function configParamUpdate()
	ret = ""
	param = jsonpayload()

	if !isnothing(param)
		ret = j_config.configParamUpdate(param)
	end

	return ret
end

end
