"""
module: PostDataController

Author: Ono keiji

Description:
	all controll for poting data from clients

functions
	initial() the first database setting to Jetelina. this is the initialize of all. once in a life.
	initialUser() register the first users into jetelina_user_table. once in a life.
	getConfigData()	get a configuration parameter data ordered by posting data.
	handleApipostdata() execute ordered API by posting data.
	createApi()  create API and SQL select sentence from posting data.
	getColumns()  get ordered tables's columns with json style.ordered table name is posted as the name 'tablename' in jsonpayload().
	deleteTable()  delete table by ordering. this function calls DBDataController.dropTable(tableName,stichwort), so 'delete' meaning is really 'drop'.ordered table name is posted as the name 'tablename' in jsonpayload().
	userRegist() register a new user
	login()  login procedure.user's login account is posted as the name 'username' in jsonpayload().
	getUserInfoKeys()  get "user_info" column key data.
	refUserAttribute() refer the user attribute after login().
	refUserInfo()	refer the user_info
	updateUserInfo() update user information data
	updateUserData() update user data
	updateUserLoginData() update user login data like logincount,logindate,.....
	deleteUserAccount() delete user account from jetelina_user_table
	deleteApi()  delete api by ordering from JC["sqllistfile"] file, then refresh the DataFrame.
	configParamUpdate()	update configuration parameter
	getRelatedTableApi() get the list of relational with 'table' or 'api'
	searchErrorLog() searching orderd log as 'errnum' in log file
	prepareDbEnvironment() database connection checking, and initializing database if needed
"""
module PostDataController

using Genie, Genie.Requests, Genie.Renderer.Json, DataFrames
using Jetelina.JFiles, Jetelina.JLog, Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.DBDataController, Jetelina.JMessage, Jetelina.JSession
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

export initialDb, initialUser, getConfigData, handleApipostdata, createApi, getColumns, deleteTable, userRegist, login, getUserInfoKeys, refUserAttribute, refUserInfo, updateUserInfo,
	updateUserData, updateUserLoginData, deleteUserAccount, deleteApi, configParamUpdate, searchErrorLog, prepareDbEnvironment

"""
	function initialDb() 
		
		the first database setting to Jetelina. this is the initialize of all. once in a life.
"""
function initialDb()
	db::String = jsonpayload("jetelinadb")
	mode::String = "init"
	param = jsonpayload()
	flg::Bool = false

	#===
		Attention:
			this session data is mandatory, because in _comfingParam.. and registering user process
			require this session data.
			indeed this 'myself' is registerd in the table at the same time of creating user table,
			and is deleted at the end of this initial process by calling deleteUser() in initialprocess.js.

			the secound param '0' is dummy. but it expectables in Postgres, but not Mysql, whichever the following
			process use the first param 'myself', do not worry. :) 
	===#
	JSession.set("myself",1)

	ret = _configParamUpdate(param)
	if DBDataController.prepareDbEnvironment(db,mode)[1]
		flg = true
	end

	return json(Dict("result" => flg, "Jetelina" => "[{}]"))
end
"""
	function initialUser() 
		
		register the first users into jetelina_user_table. once in a life.
"""
function initialUser()
	ret = ""
	users = jsonpayload("users")

	if !isnothing(users)
		for un in users
			ret = DBDataController.userRegist(un)
		end
	end

	return ret
end
"""
function getConfigData()

	get a configuration parameter data ordered by posting data.

# Arguments
- return: json data including ordered a configuration if there were. ex. {"result":true,"logfile":"log.txt"}
"""
function getConfigData()
	d = jsonpayload("param")
#	if !contains(d, "password")
		if !isnothing(j_config.JC[d])
			return json(Dict("result" => true, d => j_config.JC[d]))
		else
			return json(Dict("result" => false))
		end
#	else
		# if "password" is required
#		return json(Dict("result" => true, d => "keep it secret.(^^)v"))
#	end
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

	delete table by ordering. this function calls DBDataController.dropTable(tableName,stichwort), so 'delete' meaning is really 'drop'.
	ordered table name is posted as the name 'tablename' in jsonpayload().
"""
function deleteTable()
	ret = ""
	tableName::Vector = jsonpayload("tablename")
	stichwort::String = jsonpayload("pass")
	if !isnothing(tableName)
		ret = DBDataController.dropTable(tableName,stichwort)
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
	username = jsonpayload("username")
	if !isnothing(username)
		ret = DBDataController.userRegist(username)
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

	# set session data
	if ret["result"]
		j = ret["Jetelina"]
		#===
			Tips:
				'j' is vector tuple data. the order is to reference chkUserExistence().
				j[1][1] -> user id        
				j[1][2] -> username
				j[1][3] -> nickname
				j[1][4] -> logincount
				j[1][5] -> logindate
				j[1][6] -> logoutdate
				j[1][7] -> generation
									        so far
		===#
		if !isnothing(j) && 0<length(j)
			if !isnothing(j[1][2]) && !isnothing(j[1][1])
				JSession.set(j[1][2],j[1][1])
				#===
					Tips:
						set data base type that is used at the last login
						register default dbtype in the config, if there were no data in user_info
				===#
				u = DBDataController.refUserInfo(j[1][1], "last_dbtype", 1)
				if !ismissing(u[:, :last_dbtype][1])
					JSession.setDBType(u[:, :last_dbtype][1])
				else
					# go to register
					DBDataController.updateUserInfo(j[1][1], "last_dbtype", j_config.JC["dbtype"])
				end
			end
		end
	end

	return json(ret)
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
function refUserInfo()

	refer the user_info

# Arguments
- return: ture/false in json form
"""
function refUserInfo()
	ret = ""
	uid = jsonpayload("uid")
	key = jsonpayload("key")
	if !isnothing(uid) && !isnothing(key)
		rettype = 0 # expect json type
		ret = DBDataController.refUserInfo(uid, key, rettype)
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
	stichwort = jsonpayload("pass")
	jmsg::String = string("compliment me!")
	retapis::String = join(apis,",") # ["a","b"] -> "a,b" oh ＼(^o^)／

	if DBDataController.refStichWort(stichwort)
		if( ApiSqlListManager.deleteApiFromList(apis) )
			ret = json(Dict("result" => true, "apiname" => "$retapis", "message from Jetelina" => jmsg))
		else
			ret = json(Dict("result" => false, "apiname" => "$retapis", "errmsg" => "Oh my, failed the deleting. Type 'show error' to show somethin' if you're lucky."))
		end
	else
		ret = json(Dict("result" => false, "message from Jetelina" => "wrong pass phrase"))
	end
end
"""
function configParamUpdate()

	update configuration parameter

# Arguments
- return: ture/false in json form
"""
function configParamUpdate()
	param = jsonpayload()
	return _configParamUpdate(param)
end

function _configParamUpdate(param::Dict)
	ret = ""
	jmsg::String = string("compliment me!")
	#===
		Tips:
			as you know, 'jetelina' database should be created in mysql, not in postgresql, the reasons are ref each lib programs.
			there is no chance to create 'jetelina' database until here if postgresql were initial.
			thus, have to check the database existence and create it if there were no yet.
			you may think it should be executed in other placce, e.g. ConfigManager, but could not do it because of some dificult 
			technical reasons.(T_T)
			someday, when Genie compiler will not need .autoload sequence.
	===#
	if !isnothing(param)
		cpur::Bool = false
		key::String = ""
		value::String = ""

		if j_config.configParamUpdate(param)
			cpur = true
		end

		for (k,v) in param
			key = k
			value = v
			if k == "dbtype" && v == "mysql"
				DBDataController.createJetelinaDatabaseinMysql()
			end
		end
	

		ret = json(Dict("result" => cpur, "Jetelina" => "[{}]", "target" => key, "message from Jetelina" => jmsg))
	end

	return ret
end
"""
function getRelatedTableApi()

	get the list of relational with 'table' or 'api'

# Arguments
- return: json: contains the list data
"""
function getRelatedTableApi()
	searchKey::String = ""
	target::String = ""
	table::String = jsonpayload("table")
	api::String = jsonpayload("api")
	jmsg::String = string("compliment me!")

	if 0<length(table)
		searchKey = "table"
		target = table
	elseif 0<length(api)
		searchKey = "api"
		target = api
	end

	ret = ApiSqlListManager.getRelatedList(searchKey,target)
	if( 0<length(ret) )
		json(Dict("result" => true, "target" => target, "list" => ret, "message from Jetelina" => jmsg))
	else
		json(Dict("result" => false, "target" => target, "list" => 0, "errmsg" => "Oh my, there is no initial APIs, guess somethi' had happend at uploading file, ah..... sorry"))
	end
end
"""
function switchDB()

	switching user handle database

# Arguments
"""
function switchDB()
	db::String = jsonpayload("param")
	jmsg::String = string("compliment me!")

	if(!isnothing(db) && db != "")
		JSession.setDBType(db)
		j_config.JC["dbtype"] = db;
	end

	return json(Dict("result" => true, "message from Jetelina" => jmsg))
end
"""
function searchErrorLog()

	searching orderd log as 'errnum' in log file

# Arguments
- return::String  string in log file has 'errnum'
"""
function searchErrorLog()
	errnum = jsonpayload("errnum")
	err = JLog.searchinLogfile(errnum)
	return json(Dict("result" => true, "errlog" => "$err"))
end
"""
function prepareDbEnvironment()

	simply connection check

# Arguments
- return::String  success -> true, fail -> false
"""
function prepareDbEnvironment()
	db::String = jsonpayload("db")
	mode::String = jsonpayload("mode")
	available::Bool = false
	db_config::String = ""
	df::DataFrame = DataFrame()

	if db == "postgresql"
		available = j_config.JC["pg_work"]
		db_config = "pg_work"
		df = DataFrame("pg_host"=>j_config.JC["pg_host"],"pg_port"=>j_config.JC["pg_port"],"pg_user"=>j_config.JC["pg_user"],"pg_password"=>j_config.JC["pg_password"],"pg_dbname"=>j_config.JC["pg_dbname"],"pg_sslmode"=>j_config.JC["pg_sslmode"])
	elseif db == "mysql"
		available = j_config.JC["my_work"]
		db_config = "my_work"
		df = DataFrame("my_host"=>j_config.JC["my_host"],"my_port"=>j_config.JC["my_port"],"my_user"=>j_config.JC["my_user"],"my_password"=>j_config.JC["my_password"],"my_dbname"=>j_config.JC["my_dbname"],"my_unix_socket"=>j_config.JC["my_unix_socket"])
	elseif db == "redis"
		available = j_config.JC["redis_work"]
		db_config = "redis_work"
		df = DataFrame("redis_host"=>j_config.JC["redis_host"],"redis_port"=>j_config.JC["redis_port"],"redis_password"=>j_config.JC["redis_password"],"redis_dbname"=>j_config.JC["redis_dbname"])
	end

	ret =  DBDataController.prepareDbEnvironment(db,mode)
	if ret[1]
		if !available
			# change config parameter
			if j_config.configParamUpdate(Dict(db_config=>"true"))
		        return json(Dict("result" => true, "Jetelina" => "[{}]"))
			else
				err = """Oh my, failed at updating configuration $db_config"""
		        return json(Dict("result" => false, "Jetelina" => "[{}]", "errmsg" => "$err"))
			end
		end
	else
		err = """Ooops, failed at checkin' the connection, may need to update the connection parameters. <start>type 'show parameter'<st>which ... -> type to point parameter like 'my_password'<st>type 'change parameter'<st>set your new data for updating<end>then try again. rely on me :)"""
		return json(Dict("result" => false, "Jetelina" =>  copy.(eachrow(df)), "preciousmsg" => "$err"))
	end
end

end
