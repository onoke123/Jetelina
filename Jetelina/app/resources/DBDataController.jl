"""
	module: DBDataController

	Author: Ono keiji

	Description:
		General DB action controller

	functions
		__init__() Initial action. Execute init_Jetelina_table()
		init_Jetelina_table() Execute *.create_jetelina_table() depend on DB type.Execute *.readJetelinatable() depend on DB type.
		dataInsertFromCSV(csvfname::String) CSV data inserts into DB. It executes in *.dataInsertFromCSV depend on DB type.
		getTableList(s::String) Get the ordered table list by executing *.getTable() depend on DB type
		dropTable(tableName::Vector) Drop the tables and delete its related data from jetelina_table_manager table
		getColumns(tableName::String) Get columns of ordered table name depend on DB type.
		doSelect(sql::String,mode::String)
		executeApi(json_d) Execute SQL sentence order by json_d: json raw data.
		userRegist(username::String) register a new user
		chkUserExistence(s::String) pre login, check the ordered user in jetelina_user_table or not
		getUserInfoKeys(uid::Integer) get "user_info" column key data.
		refUserAttribute(uid::Integer,key::String,val) inquiring user_info data 
		updateUserInfo(uid::Integer,key::String,value) update user data (jetelina_user_table.user_info)
		updateUserData(uid::Integer,key::String,value) update user data, exept jsonb column
		updateUserLoginData(uid::Integer) update user login data if it succeeded to login
		deleteUserAccount(uid::Integer) user delete, but not physical deleting, set jetelina_delete_flg to 1. 
		createApiSelectSentence(json_d::Dict,mode::String) create API and SQL select sentence from posting data.
"""

module DBDataController

using DataFrames, Genie, Genie.Renderer, Genie.Renderer.Json
using Jetelina.ApiSqlListManager, Jetelina.JMessage, Jetelina.JLog
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

#===
	Note: 
		wanna these include() in init(), but not alll DBData.. is been included(), thus sometimes 'not found method ..' happen.
	    guess should have a procedure alike JTimer.jl, I mean should include these in a dummy file to kick init(). :P  2024/2/10
===#
include("libs/postgres/PgDBController.jl")
include("libs/postgres/PgSQLSentenceManager.jl")

export init_Jetelina_table,
	dataInsertFromCSV, getTableList, getSequenceNumber, dropTable, getColumns, doSelect,
	executeApi, userRegist, chkUserExistence, getUserInfoKeys, refUserAttribute, updateUserInfo, updateUserData, deleteUserAccount,
	createApiSelectSentence


"""
function __init__()
	Initial action. Execute init_Jetelina_table()
"""
function __init__()
	@info "==========DBDataController init================"
	#===
		Note: 
			if got error as "LoadError: MethodError: Method too new to be called from this world context.", this function maybe need to use invokelatest().
				ex. invokelatest(init_Jete....) or @invokelatest init_Jete....
			ref. https://stackoverflow.com/questions/69492334/loaderror-methoderror-method-too-new-to-be-called-from-this-world-context-i
	===#
	init_Jetelina_table()
end
"""
function init_Jetelina_table()
	Execute *.create_jetelina_table() depend on DB type.
	Execute *.readJetelinatable() depend on DB type.
"""
function init_Jetelina_table()
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
#    these two procedures should be moved to "CREATION" method
#		PgDBController.create_jetelina_id_sequence()
#		PgDBController.create_jetelina_table()

#  	the process in this function is deprecated
#		PgDBController.readJetelinatable()

	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end

end
"""
function dataInsertFromCSV(csvfname::String)

	CSV data inserts into DB. It executes in *.dataInsertFromCSV depend on DB type.

# Arguments
- `csvfname: String`: csv file name. Expect string data of JC["fileuploadpath"] + <csv file name>.
"""
function dataInsertFromCSV(csvfname::String)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		return PgDBController.dataInsertFromCSV(csvfname)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function getTableList(s::String)

	Get the ordered table list by executing *.getTable() depend on DB type

# Arguments
- `s::String`:  return data type. Typically 'json'.
"""
function getTableList(s::String)
	if isnothing(s)
		s = "json"
	end

	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.getTableList(s)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function dropTable(tableName::Vector)
		
	Drop the tables and delete its related data from jetelina_table_manager table

# Arguments
- `tableName: Vector`: name of the tables
"""
function dropTable(tableName::Vector)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		ret = PgDBController.dropTable(tableName)
		if ret[1]
			# update SQL list
			ApiSqlListManager.deleteTableFromlist(tableName)
		end
		#==
			Tips:
				ret[2] is expected
					delete succeeded
						json(Dict("result" => true, "tablename" => "$tableName", "message from Jetelina" => jmsg))
					something error happened
						json(Dict("result" => false, "tablename" => "$tableName", "errmsg" => "$err"))
		==#
		return ret[2]
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function getColumns(tableName::String)

	Get columns of ordered table name depend on DB type.

# Arguments
- `tableName: String`: DB table name
"""
function getColumns(tableName::String)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.getColumns(tableName)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function doSelect(sql::String,mode::String)

	execute select sentence depend on DB type.

	Attention: 2024/3/20
		mode="run" does not be used indeed, because this doSelect() is called when measuring its performance.
		true API execution does with executeApi().
		pre execution mode uses this function therefore its only select sentence in SQL.

# Arguments
- `sql: String`: execute sql sentense
- `mode: String`: "run"->running mode  "measure"->measure speed. only called by measureSqlPerformance() "pre"->test exection before creating API        
"""
function doSelect(sql::String, mode::String)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.doSelect(sql,mode)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function executeApi(json_d)

	Execute SQL sentence order by d: json raw data.
	
# Arguments
- `json_d`:  json raw data, uncertain data type        
"""
function executeApi(json_d::Dict)
	ret = ""
	sql_str = ""
	#===
		Tips:
			Steps
				1.search sql in Df_JetelinaSqlList with d["apino"]
				ex. ji1 -> update <table> set name='{name}', age={age} where jt_id={jt_id}
				2.json data bind to the sql sentence
				3.execute the binded sql sentence
	===#
	# Step1
	#===
		Tips:
			use subset() here, because Df_JetelinaSqlList may have missing data.
			subset() supports 'skipmissing', but filter() does not.
	===#
	if ApiSqlListManager.readSqlList2DataFrame()[1]
		Df_JetelinaSqlList = ApiSqlListManager.readSqlList2DataFrame()[2]
		target_api = subset(Df_JetelinaSqlList, :apino => ByRow(==(json_d["apino"])), skipmissing = true)
		if 0 < nrow(target_api)
			# Step2:
			if j_config.JC["dbtype"] == "postgresql"
				# Case in PostgreSQL
				ret = PgDBController.executeApi(json_d, target_api)
			end
		elseif j_config.JC["dbtype"] == "mariadb"
		elseif j_config.JC["dbtype"] == "oracle"
		end
	else
		# not found SQL list 
	end

	# write execution sql to log file
	JLog.writetoSQLLogfile(json_d["apino"], sql_str)

	return ret
end
"""
function userRegist()

	register a new user

# Arguments
- `username::String`:  user name. this data sets in as 'login','firstname' and 'lastname' at once.
- return::boolean: success->true  fail->false
"""
function userRegist(username::String)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.userRegist(s)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function chkUserExistence(s::String)

	pre login, check the ordered user in jetelina_user_table or not
	search only alive user (jetelina_delete_flg=0)
	resume to refUserAttribute() if existed
	
# Arguments
- `s::String`:  user information. login account or first name or last name.
- return: success -> user data in json, fail -> ""
"""
function chkUserExistence(s::String)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.chkUserExistence(s)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function getUserInfoKeys(uid::Integer)

	get "user_info" column key data.

# Arguments
- `uid::Integer`: expect user_id
- return: success -> user data in json or DataFrame, fail -> ""
"""
function getUserInfoKeys(uid::Integer)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.getUserInfoKeys(uid)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function refUserAttribute(uid::Integer,key::String,val)

	inquiring user_info data 
	
# Arguments
- `uid::Integer`: expect user_id
- `key::String`: key name in user_info json data
- `val`:  user input data. not sure the data type. String or Integer or something else
- return: success -> user data in json or DataFrame, fail -> ""
"""
function refUserAttribute(uid::Integer, key::String, val)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		rettype::Integer = 0 # because wanna the return as json type
		PgDBController.refUserAttribute(uid, key, val, rettype)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function updateUserInfo(uid::Integer,key::String,value)

	update user data (jetelina_user_table.user_info)

# Arguments
- `uid::Integer`: expect user_id
- `key::String`: key name in user_info json data
- `val`:  user input data. not sure the data type. String or Integer or something else
- return: success -> true, fail -> error message
"""
function updateUserInfo(uid::Integer, key::String, value)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.updateUserInfo(uid, key, val)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function updateUserData(uid::Integer,key::String,value)

	update user data, exept jsonb column
	this function can use for simple columns.

# Arguments
- `uid::Integer`: expect user_id
- `key::String`: name of countable columns. ex. logincount,user_level...
- `val::Integer`: data to set the ordered column  
- return: success -> true, fail -> error message
"""
function updateUserData(uid::Integer, key::String, value)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.updateUserData(uid, key, value)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function updateUserLoginData(uid::Integer)

	update user login data if it succeeded to login

# Arguments
- `uid::Integer`: expect user_id
- return: success -> true, fail -> error message
"""
function updateUserLoginData(uid::Integer)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.updateUserLoginData(uid)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function deleteUserAccount(uid::Integer)

	user delete, but not physical deleting, set jetelina_delete_flg to 1. 

# Arguments
- `uid::Integer`: expect user_id
- return: success -> true, fail -> error message
"""
function deleteUserAccount(uid::Integer)
	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		PgDBController.deleteUserAccount(uid)
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end
end
"""
function createApiSelectSentence(json_d::Dict,mode::String)

	create API and SQL select sentence from posting data.

# Arguments
- `json_d::Dict`:  json raw data, uncertain data type        
- `mode::String`:  execution mode  "ok" -> ultimate execution  "pre"->pre execution before creating API        
- return: this sql is already existing -> json {"resembled":true}
		  new sql then success to append it to  -> json {"apino":"<something no>"}
					   fail to append it to     -> false
"""
function createApiSelectSentence(json_d::Dict, mode::String)
	ret = ""

	if j_config.JC["dbtype"] == "postgresql"
		# Case in PostgreSQL
		if mode == "ok"
			sqn = PgDBController.getJetelinaSequenceNumber(1) # attr '1' means 'jetelian_sql_sequence'. see its function.
		elseif mode == "pre"
			sqn = -1
		end

		if sqn isa Integer
			ret = PgSQLSentenceManager.createApiSelectSentence(json_d, sqn)
			if mode == "pre"
				#===
					Tips:
						in the case of mode="pre", PgSQLSente...createApiSelect...() returns SQL sentence for pre executing.
						it could not execute in PgSQLSentenceManager because of the relation in 'using'. :P 
				===#
				ret = PgDBController.doSelect(ret,"pre")
			end
		else
			ret = "fail: Illegal Sequence Number"
		end
	elseif j_config.JC["dbtype"] == "mariadb"
	elseif j_config.JC["dbtype"] == "oracle"
	end

	return ret
end

end
