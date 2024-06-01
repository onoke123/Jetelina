"""
module: PgDBController

Author: Ono keiji

Description:
	DB controller for PostgreSQL

functions
	create_jetelina_tables() create 'jetelina_table_manager' table.
	create_jetelina_id_sequence() create 'jetelina_table_id_sequence','jetelina_sql_sequence' and 'jetelina_user_id_sequence' sequence.
	open_connection() open connection to the DB.
	close_connection(conn::LibPQ.Connection)  close the DB connection
	readJetelinatable() read all data from jetelina_table_manager then put it into Df_JetelinaTableManager DataFrame 
	getTableList(s::String) get all table name from public 'schemaname'
	getJetelinaSequenceNumber(t::Integer) get seaquence number from jetelina_id table
	insert2JetelinaTableManager(tableName::String, columns::Array) insert columns of 'tableName' into Jetelina_table_manager  
	dataInsertFromCSV(fname::String) insert csv file data ordered by 'fname' into table. the table name is the csv file name.
	dropTable(tableName::Vector) drop the tables and delete its related data from jetelina_table_manager table
	getColumns(tableName::String) get columns name of ordereing table.
	executeApi(json_d::Dict,target_api::DataFrame) execute API order by json data
	_executeApi(apino::String, sql_str::String) execute API with creating SQL sentence,this is a private function that is called by executeApi()
	doSelect(sql::String,mode::String) execute select data by ordering sql sentence, but get sql execution time of ordered sql if 'mode' is 'measure'.
	measureSqlPerformance() measure exectution time of all listed sql sentences. then write it out to JC["sqlperformancefile"].
	create_jetelina_user_table() create 'jetelina_table_user_table' table.
	userRegist(username::String) register a new user
	getUserData(s::String) get jetelina user data by ordering 's'.	
	chkUserExistence(s::String) pre login, check the ordered user in jetelina_user_table or not
	getUserInfoKeys(uid::Integer) get "user_info" column key data.
	refUserAttribute(uid::Integer,key::String,val) inquiring user_info data 
	updateUserInfo(uid::Integer,key::String,value) update user data (jetelina_user_table.user_info)
	updateUserData(uid::Integer,key::String,value) update user data, exept jsonb column
	updateUserLoginData(uid::Integer) update user login data if it succeeded to login
	deleteUserAccount(uid::Integer) user delete, but not physical deleting, set jetelina_delete_flg to 1. 
	checkTheRoll(roll::String) check the ordered user's authority in order to 'roll'.
"""
module PgDBController

using Genie, Genie.Renderer, Genie.Renderer.Json
using CSV, LibPQ, DataFrames, IterTools, Tables, Dates
using Jetelina.JFiles, Jetelina.JLog, Jetelina.ApiSqlListManager, Jetelina.JMessage, Jetelina.JSession
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

include("PgDataTypeList.jl")
include("PgSQLSentenceManager.jl")

export create_jetelina_table, create_jetelina_id_sequence, open_connection, close_connection, readJetelinatable,
	getTableList, getJetelinaSequenceNumber, insert2JetelinaTableManager, dataInsertFromCSV, dropTable, getColumns,
	executeApi, doSelect, measureSqlPerformance, create_jetelina_user_table, userRegist, getUserData, chkUserExistence, getUserInfoKeys,
	refUserAttribute, updateUserInfo, updateUserData, deleteUserAccount, checkTheRoll

"""
function create_jetelina_table

	create 'jetelina_table_manager' table.

	deprecated

	Attention: jetelina_table_manager is prepared for if table layouts have to be changed in Jetelina prototype.
			   this table maintain an original relation between table and columns. this table would be updated if
			   a column moved to other table, for example table_A.age and table_B.sex were united to as table_C, then
			   *.age and *.sex should be table_C.age and table_C.sex, but maybe needed their origins when they are 
			   updated and/or insert, I am not sure.
			   In PostgreSQL, this table has been deprecated because of hiring 'incremental materialized view' system.
			   I would like to leave this function as a reference func when have a chance similar function for other DB systems.
"""
function create_jetelina_table()
	create_jetelina_table_manager_str = """
		create table if not exists jetelina_table_manager(
			jetelina_id varchar(256), table_name varchar(256), columns varchar(256)
		);
	"""
	conn = open_connection()
	try
		execute(conn, create_jetelina_table_manager_str)
	catch err
		JLog.writetoLogfile("PgDBController.create_jetelina_table() error: $err")
	finally
		close_connection(conn)
	end
end

"""
function create_jetelina_id_sequence()

	create 'jetelina_table_id_sequence','jetelina_sql_sequence' and 'jetelina_user_id_sequence' sequence.

	jetelina_table_id is deprecated
"""
function create_jetelina_id_sequence()
	#===
	jetelina_id_sequence = """
		create sequence jetelina_table_id_sequence;create sequence jetelina_sql_sequence;create sequence jetelina_user_id_sequence;
	"""
	===#
	jetelina_id_sequence = """
		create sequence create sequence jetelina_sql_sequence;create sequence jetelina_user_id_sequence;
	"""
	conn = open_connection()
	try
		execute(conn, jetelina_id_sequence)
	catch err
		JLog.writetoLogfile("PgDBController.create_jetelina_id_sequence() error: $err")
	finally
		close_connection(conn)
	end
end

"""
function open_connection()

	open connection to the DB.
	connection parameters are set by global variables.

# Arguments
- return: LibPQ.Connection object
"""
function open_connection()
	con_str = string("host='", j_config.JC["pg_host"],
		"' port='", j_config.JC["pg_port"],
		"' user='", j_config.JC["pg_user"],
		"' password='", j_config.JC["pg_password"],
		"' sslmode='", j_config.JC["pg_sslmode"],
		"' dbname='", j_config.JC["pg_dbname"], "'")

	return conn = LibPQ.Connection(con_str)
end

"""
function close_connection(conn::LibPQ.Connection)

	close the DB connection

# Arguments
- `conn:LibPQ.Connection`: LibPQ.Connection object
"""
function close_connection(conn::LibPQ.Connection)
	close(conn)
end

"""
function readJetelinatable()

	read all data from jetelina_table_manager then put it into Df_JetelinaTableManager DataFrame

	Attention: this function is deprecated in ver.1, but will be revived someday, who knows. :P

# Arguments
- return: boolean:  true->success, false->fail
"""
function readJetelinatable()
	sql = """   
		select
			*
		from jetelina_table_manager
	"""
	conn = open_connection()
	try
		global Df_JetelinaTableManager = DataFrame(columntable(LibPQ.execute(conn, sql)))
	catch err
		JLog.writetoLogfile("PgDBController.readJetelinatable() error: $err")
		return false
	finally
		close_connection(conn)
	end

	if j_config.JC["debug"]
		@info "PgDBController.readJetelinatable() Df_JetelinaTableManager: " Df_JetelinaTableManager
	end

	return true
end

"""
function getTableList(s::String)

	get all table name from public 'schemaname'

# Arguments
- `s:String`: 'json' -> required JSON form to return
			'dataframe' -> required DataFrames form to return
- return: table list in json or DataFrame

"""
function getTableList(s::String)
	df = _getTableList()
	if s == "json"
		return json(Dict("result" => true, "Jetelina" => copy.(eachrow(df))))
	elseif s == "dataframe"
		return df
	end
end
"""
function _getTableList()

	get table list then put it into DataFrame object. this is a private function, but can access from others
	fixing as 'public' in schemaname. this is the protocol.

# Arguments
- return: DataFrame object. empty if got fail.
"""
function _getTableList()
	df = DataFrame()
	conn = open_connection()
	# Fixing as 'public' in schemaname. This is the protocol.
	table_str = """select tablename from pg_tables where schemaname='public'"""
	try
		df = DataFrame(columntable(LibPQ.execute(conn, table_str)))
		# do not include 'jetelina_table_manager and usertable in the return
		DataFrames.filter!(row -> row.tablename != "jetelina_table_manager" && row.tablename != "jetelina_user_table", df)
	catch err
		JLog.writetoLogfile("PgDBController._getTableList() error: $err")
		return DataFrame() # return empty DataFrame if got fail
	finally
		close_connection(conn)
	end

	return df
end
"""
function getJetelinaSequenceNumber(t::Integer)

	get seaquence number from jetelina_id table

# Arguments
- `t: Integer`  : type order  0-> jetelina_table_id, 1-> jetelian_sql_sequence
- return: 0< sequence number   -1 fail
"""
function getJetelinaSequenceNumber(t::Integer)
	conn = open_connection()
	ret = -1
	try
		ret = _getJetelinaSequenceNumber(conn, t)
	catch err
		JLog.writetoLogfile("PgDBController.getJetelinaSequenceNumber() error: $err")
	finally
		close_connection(conn)
	end

	return ret
end

"""
function _getJetelinaSequenceNumber(conn::LibPQ.Connection, t::Integer)

	get seaquence number from jetelina_table_id_sequence or jetelina_sql_sequence or jetelina_user_id_sequence, but this is a private function.
	this function will never get fail, expectedly.:-P

	jetelina_table_id is deprecated

# Arguments
- `conn: Object`: connection object
- `t: Integer`  : type order  0-> jetelina_table_id_sequence, 1-> jetelian_sql_sequence 2->jetelina_user_id_sequence
- return:Integer: sequence number 
"""
function _getJetelinaSequenceNumber(conn::LibPQ.Connection, t::Integer)
	sql = ""

	if t == 0
		#===
				sql = """
					select nextval('jetelina_table_id_sequence');
				"""
		===#
	elseif t == 1
		sql = """
			select nextval('jetelina_sql_sequence');
		"""
	elseif t == 2
		sql = """
			select nextval('jetelina_user_id_sequence');
		"""
	end

	sequence_number = columntable(execute(conn, sql))

	#===
		Tips:
		this sequence_number is a type of Union{Missing,Int64}{51} for example.
		wanted nextval() is {51}, then 
			sequence_number[1] -> Union{Int64}[51]
			sequence_number[1][1] -> 51
	===#
	return sequence_number[1][1]
end

"""
function insert2JetelinaTableManager(tableName::String, columns::Array )

	insert columns of 'tableName' into Jetelina_table_manager  

# Arguments
- `tableName: String`: table name of insertion
- `columns: Array`: vector arrya for insert column data
- return: boolean: fail if got error. nothing return in the caes of success
"""
function insert2JetelinaTableManager(tableName::String, columns::Array)
	conn = open_connection()

	try
		jetelina_table_id = getJetelinaSequenceNumber(conn, 0)

		for i ∈ 1:length(columns)
			c = columns[i]
			values_str = "'$jetelina_table_id','$tableName','$c'"

			if j_config.JC["debug"]
				@info "PgDBController.insert2JetelinaTableManager() insert str:" values_str
			end

			insert_str = """
				insert into Jetelina_table_manager values($values_str);
			"""
			execute(conn, insert_str)
		end
	catch err
		JLog.writetoLogfile("PgDBController.insert2JetelinaTableManager() error: $err")
		return false
	finally
		close_connection(conn)
	end

	# update Df_JetelinaTableManager
	#readJetelinatable()
end

"""
function dataInsertFromCSV(fname::String)

	insert csv file data ordered by 'fname' into table. the table name is the csv file name.

# Arguments
- `fname: String`: csv file name
- return: boolean: true -> success, false -> get fail
"""
function dataInsertFromCSV(fname::String)
	keyword1::String = "jetelina_delete_flg"
	keyword2::String = "jt_id"
	keyword3::String = "unique"
	ret = ""
	jmsg::String = string("compliment me!")

	df = DataFrame(CSV.File(fname))
	rename!(lowercase, df)

	#===
		new table name is the csv file name with deleting the suffix  
			ex. /home/upload/test.csv -> splitdir() -> ("/home/upload","test.csv") -> splitext() -> ("test",".csv")
	===#
	tableName = splitext(splitdir(fname)[2])[1]
	#===
		Tips:
			Postgresql does not forgive to use '-' in a table name
	===#
	tableName = replace(tableName, "-" => "_")
	#===
		Tips:
			original column names in the csv file are changed here because of making it unique.
			keyword2(jt_id) is also changed at the same time.
			then consequently the 'column_name' are <table name>_<column name>.
	===#
	colarray = []
	for col in names(df)
		push!(colarray, string(tableName, '_', col))
	end

	rename!(df, Symbol.(colarray))
	keyword2 = string(tableName, '_', keyword2)

	# special column 'jetelina_delte_flg' is added to columns 
	insertcols!(df, :jetelina_delete_flg => 0)

	column_name = names(df)

	column_type = eltype.(eachcol(df))
	column_type_string = Array{Union{Nothing, String}}(nothing, length(column_name)) # using for creating table
	column_str = string() # using for creating table
	insert_column_str = string() # columns definition string
	insert_data_str = string() # data string
	update_str = string()
	tablename_arr::Vector{String} = []

	#===
		make the sentece of sql( "id integer, name varchar(36)...")
	===#
	for i ∈ 1:length(column_name)
		#===
			Tips:
				the reason for this connection, see in doSelect()
		===#
		cn = column_name[i]
		column_type_string[i] = PgDataTypeList.getDataType(string(column_type[i]))
		if contains(cn, keyword2)
			column_str = string(column_str, " ", cn, " ", column_type_string[i], " ", keyword3)
		else
			column_str = string(column_str, " ", cn, " ", column_type_string[i])
		end

		insert_column_str = string(insert_column_str, "$cn")
		if startswith(column_type_string[i], "varchar")
			#string data
			insert_data_str = string(insert_data_str, "'{$cn}'")
			update_str = string(update_str, "$cn='{$cn}'")
		else
			#number data
			insert_data_str = string(insert_data_str, "{$cn}")
			if !contains(cn, keyword1) && !contains(cn, keyword2)
				update_str = string(update_str, "$cn={$cn}")
			end
		end

		if 0 < i < length(column_name)
			column_str = string(column_str, ",")
			insert_column_str = string(insert_column_str, ",")
			insert_data_str = string(insert_data_str, ",")
			#==
				Tips:
					because 'jetelina_delete_flg' always comes into the tail
			==#
			if i < length(column_name) - 1
				update_str = string(update_str, ",")
			end
		end
	end

	#===
		Tips:
			There is a reason.....
			in the above, 'update_str' has ',' at its head because of rejecting 'jt_id' column.
			'jt_id' is always head of the columns, and it puzzled to build 'update_str' if rejected it.
			that's why using lstrip(). dum it. :p
	===#
	if startswith(update_str, ",")
		update_str = lstrip(update_str, ',')
	end

	if j_config.JC["debug"]
		@info "PgDBController.dataInsertFromCSV() col str to create table: " column_str
	end

	#===
		check if the same name table already exists.
		this is not for create sql, but for insert2JetelinaTableManager().
	===#
	df_tl = _getTableList()
	DataFrames.filter!(row -> row.tablename == tableName, df_tl)

	#===
		Tips:
		create table with 'not exists'.
		then insert csv data to there. this is because of forgiving adding data to the same table.
		put isempty(df_tl) in there as same as insert2JetelinaTableManager if it does not forgive it.
	===#
	create_table_str = """
		create table if not exists $tableName(
			$column_str   
		);
	"""
	conn = open_connection()
	try
		execute(conn, create_table_str)
	catch err
		close_connection(conn)
		ret = json(Dict("result" => false, "filename" => "$fname", "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.dataInsertFromCSV() with $fname error : $err")
		return ret
	finally
		# do not close the connection because of resuming below yet.
	end
	#===
		then get column from the created table, because the columns are order by csv file, thus they can get after
		created the table
	===#
	sql = """   
		SELECT
			*
		from $tableName
		"""
	df0 = DataFrame(columntable(LibPQ.execute(conn, sql)))
	rename!(lowercase, df0)
	cols = map(x -> x, names(df0))
	select!(df, cols)

	# create rows
	row_strings = imap(eachrow(df)) do row
		join((ismissing(x) ? "null" : x for x in row), ",") * "\n"
	end

	copyin = LibPQ.CopyIn("COPY $tableName FROM STDIN (FORMAT CSV);", row_strings)
	try
		execute(conn, copyin)
		ret = json(Dict("result" => true, "filename" => "$fname", "message from Jetelina" => jmsg))
	catch err
		#            println(err)
		ret = json(Dict("result" => false, "filename" => "$fname", "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.dataInsertFromCSV() with $fname error : $err")
		return ret
	finally
		# ok. close the connection finally
		close_connection(conn)
	end
	#===
		Tips:
		cols(see above) is ["id", "name", "sex", "age", "ave", "jetelina_delete_flg"], so can use it when
		wanna use column name, but need to judge the data type both the case of 'insert' and 'update', 
		that why do not use cols here. writing select sentence is done in PgSQLSentenceManager.createApiSelectSentence(). 
	===#
	push!(tablename_arr, tableName)
	insert_str = PgSQLSentenceManager.createApiInsertSentence(tableName, insert_column_str, insert_data_str)
	#        PgSQLSentenceManager.writeTolist(insert_str, "", tablename_arr)
	ApiSqlListManager.writeTolist(insert_str, "", tablename_arr, getJetelinaSequenceNumber(1))

	# update
	update_str = PgSQLSentenceManager.createApiUpdateSentence(tableName, update_str)
	#        PgSQLSentenceManager.writeTolist(update_str[1], update_str[2], tablename_arr)
	ApiSqlListManager.writeTolist(update_str[1], update_str[2], tablename_arr, getJetelinaSequenceNumber(1))

	# delete
	delete_str = PgSQLSentenceManager.createApiDeleteSentence(tableName)
	#        PgSQLSentenceManager.writeTolist(delete_str[1], delete_str[2], tablename_arr)
	ApiSqlListManager.writeTolist(delete_str[1], delete_str[2], tablename_arr, getJetelinaSequenceNumber(1))

	if isempty(df_tl)
		# manage to jetelina_table_manager
		insert2JetelinaTableManager(tableName, names(df0))
	end

	return ret
end

"""
function dropTable(tableName::Vector)

	drop the tables and delete its related data from jetelina_table_manager table

# Arguments
- `tableName: Vector`: ordered tables name
- return: tuple (boolean: true -> success/false -> get fail, JSON)
"""
function dropTable(tableName::Vector)
	ret = ""
	jmsg::String = string("compliment me!")
	rettables::String = join(tableName, ",") # ["a","b"] -> "a,b" oh ＼(^o^)／

	conn = open_connection()
	try

		for i in eachindex(tableName)
			# drop the tableName
			drop_table_str = string("drop table ", tableName[i])
			# delete the related data from jetelina_table_manager
			delete_data_str = string("delete from jetelina_table_manager where table_name = '", tableName[i], "'")

			execute(conn, drop_table_str)
			execute(conn, delete_data_str)
		end

		ret = json(Dict("result" => true, "tablename" => "$rettables", "message from Jetelina" => jmsg))
	catch err
		ret = json(Dict("result" => false, "tablename" => "$rettables", "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.dropTable() with $rettables error : $err")
		return false, ret
	finally
		close_connection(conn)
	end

	return true, ret
end

"""
function getColumns(tableName::String)

	get columns name of ordereing table.

# Arguments
- `tableName: String`: DB table name
- return: String: in success -> column data in json, in fail -> ""
"""
function getColumns(tableName::String)
	ret = ""
	jmsg::String = string("compliment me!")


	sql = """   
		SELECT
			*
		from $tableName
		LIMIT 1
		"""
	conn = open_connection()
	try
		df = DataFrame(columntable(LibPQ.execute(conn, sql)))
		cols = map(x -> x, names(df))
		select!(df, cols)

		ret = json(Dict("result" => true, "tablename" => "$tableName", "Jetelina" => copy.(eachrow(df)), "message from Jetelina" => jmsg))
	catch err
		ret = json(Dict("result" => false, "tablename" => "$tableName", "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.getColumns() with $tableName error : $err")
	finally
		close_connection(conn)
	end

	return ret
end
"""
function executeApi(json_d::Dict,target_api::DataFrame)

	execute API order by json data
	this function is a parent function that calls _executeApi()
	determine the target then executs it in _executeApi()

# Arguments
- `json_d::Dict`:  json raw data, uncertain data type        
- `target_api::DataFrame`: a part of api/sql DataFrame data        
- return: insert/update/delete -> true/false
		select               -> json format data
		error                -> false
"""
function executeApi(json_d::Dict, target_api::DataFrame)
	ret = ""
	sql_str = PgSQLSentenceManager.createExecutionSqlSentence(json_d, target_api)
	if 0 < length(sql_str)
		ret = _executeApi(json_d["apino"], sql_str)
	end

	return ret
end
"""
function _executeApi(apino::String,sql_str::String)

	execute API with creating SQL sentence
	this is a private function that is called by executeApi()

# Arguments
- `apino::String`:  apino
- `sql_str::String`: execution SQL string        
- return: insert/update/delete -> true/false
		select               -> json format data
		error                -> false
"""
function _executeApi(apino::String, sql_str::String)
	ret = ""

	conn = open_connection()
	try
		sql_ret = LibPQ.execute(conn, sql_str)
		#===
			Tips:
				case in insert/update/delete, we cannot see if it got success or not by .execute().
				using .num_affected_rows() to see the worth.
					in insert -> 0: normal end, the fault is caught in 'catch'
					in update/delete -> 0: swing and miss
									 -> 1: hit the ball
		===#
		affected_ret = LibPQ.num_affected_rows(sql_ret)
		jmsg::String = string("compliment me!")

		if startswith(apino, "js")
			# select 
			df = DataFrame(sql_ret)
			pagingnum = parse(Int, j_config.JC["paging"])
			if pagingnum < nrow(df)
				jmsg = string("data number over ", pagingnum, " you should set paging paramter in this SQL, it is not my business")
			end

			ret = json(Dict("result" => true, "Jetelina" => copy.(eachrow(df)), "message from Jetelina" => jmsg))
		elseif startswith(apino, "ji")
			# insert
			if affected_ret == 0
				# this may will not happen
				jmsg = "looks happen something, it is not my fault."
			end

			ret = json(Dict("result" => true, "Jetelina" => "[{}]", "message from Jetelina" => jmsg))
		else
			# update & delete
			if affected_ret == 0
				# the target data was not in there, guess wrong 'jt_id'
				jmsg = "there was not it, jt_id is correct?. no matter what it is not my business."
			end

			ret = json(Dict("result" => true, "Jetelina" => "[{}]", "message from Jetelina" => jmsg))
		end
	catch err
		JLog.writetoLogfile("PgDBController.executeApi() with $apino : $sql_str error : $err")
		ret = json(Dict("result" => false, "apino" => "$apino", "errmsg" => "$err"))
	finally
		# close the connection finally
		close_connection(conn)
	end

	return ret
end
"""
function doSelect(sql::String,mode::String)

	execute select data by ordering sql sentence, but get sql execution time of ordered sql if 'mode' is 'measure'.
	'mode=mesure' is for the condition panel feture.

	Attention: 2024/3/20
		mode="run" does not be used indeed, because this doSelect() is called when measuring its performance.
		true API execution does with executeApi().
		pre execution mode uses this function therefore its only select sentence in SQL.

# Arguments
- `sql: String`: execute sql sentense
- `mode: String`: "run"->running mode  "measure"->measure speed. only called by measureSqlPerformance() "pre"->test exection before creating API
- return: not 'mesure' mode -> sql execution result in json form
		'mesure' mode -> exectution time of tuple(max,min,mean) 
"""
function doSelect(sql::String, mode::String)
	conn = open_connection()
	ret = ""
	try
		if mode == "measure"
			#===
				aquire data types are max,best and mean
			===#
			exetime = []
			looptime = 10
			for loop in 1:looptime
				stats = @timed z = LibPQ.execute(conn, sql)
				push!(exetime, stats.time)
			end

			return findmax(exetime), findmin(exetime), sum(exetime) / looptime

		end

		#===
			Caution:
				DataFrame() spits out error so that it could not resolve the column name if there were same ones.
					ex. select ftest.name, ftest3.name ..... -> "name" is duplicated in LibPG.execute() therefore DataFrame() confuses

				to resolve it, '*' are there. ref: https://github.com/iamed2/LibPQ.jl/issues/107
				but it ':auto' in DataFrame() creates quite new column name.
				Jetelina wanna return the table column anyhow, cannot take this process.
				then changed CSV file storing to table to use the "table name" with the column name. see dataInsertFromCSV()
					ex. old: ftest.csv  has columns 'name','sex'   -> table name: ftest, column name: name, sex
						new:                〃                     -> table name:   〃 , column name: ftest_name, ftest_sex

				but it still has possibility in the case of direct import data to table by user hand. 
				threfore this is to be written in Jetelina manual as a regulation.4
		===#
		#*		result = LibPQ.execute(conn, sql)
		#*		vector_data = [convert(Vector,col) for col in Tables.columns(result)]
		#*		df = DataFrame(vector_data,:auto)
		df = DataFrame(columntable(LibPQ.execute(conn, sql)))
		jmsg::String = ""

		if parse(Int, j_config.JC["selectlimit"]) < nrow(df)
			dfmax::Integer = nrow(df)
			if !contains(sql, "limit")
				sql = string(sql, " limit 10")
				#*				result = LibPQ.execute(conn, sql)
				#*				vector_data = [convert(Vector,col) for col in Tables.columns(result)]
				#*				df = DataFrame(vector_data,:auto)
				df = DataFrame(columntable(LibPQ.execute(conn, sql)))
				jmsg = "this return is limited in 10 because the true result is $dfmax"
			end
		end

		return json(Dict("result" => true, "message from Jetelina" => jmsg, "Jetelina" => copy.(eachrow(df))))
	catch err
		JLog.writetoLogfile("PgDBController.doSelect() with $mode $sql error : $err")
		return false, err
	finally
		# close the connection finally
		close_connection(conn)
	end
end
"""
function measureSqlPerformance()

	measure exectution time of all listed sql sentences. then write it out to JC["sqlperformancefile"].
	Attention: JC["experimentsqllistfile"] is created when SQLAnalyzer.main()(indeed createAnalyzedJsonFile()) runs.
			   JC["experimentsqllistfile"] does not created if there were not sql.log file and data in it.

"""
function measureSqlPerformance()
	#===
		Tips:
			I know it can use Df_JetelinaSqlList here, but wanna leave a evidence what sql are executed.
			That's reason why JC["experimentsqllistfile"] file is opend here.
	===#
	sqlFile = getFileNameFromConfigPath(JC["experimentsqllistfile"])
	if isfile(sqlFile)
		sqlPerformanceFile = getFileNameFromConfigPath(JC["sqlperformancefile"])

		open(sqlPerformanceFile, "w") do f
			println(f, string(JC["file_column_apino"], ',', JC["file_column_max"], ',', JC["file_column_min"], ',', JC["file_column_mean"]))
			df = CSV.read(sqlFile, DataFrame)
			for i in 1:size(df, 1)
				if startswith(df.apino[i], "js")
					p = doSelect(df.sql[i], "measure")
					fno::String = df.apino[i]
					fmax::Float64 = p[1][1]
					fmin::Float64 = p[2][1]
					fmean::Float64 = p[3]
					s = """$fno,$fmax,$fmin,$fmean"""
					println(f, s)
				end
			end
		end
	end
end
"""
function create_jetelina_user_table()

	create 'jetelina_table_user_table' table.

"""
function create_jetelina_user_table()
	#===
	create_jetelina_user_table_str = """
		create table if not exists jetelina_user_table(
			user_id integer not null primary key,
			login varchar(256) not null,
			firstname varchar(256),
			lastname varchar(256),
			nickname varchar(256),
			logincount integer not null default 0,
			logindate timestamp with time zone,
			user_info jsonb,
			user_level integer not null default 0,
			familiar_index integer default 0,
			jetelina_delete_flg integer default 0
		);
	"""
	===#
	create_jetelina_user_table_str = """
		create table if not exists jetelina_user_table(
			user_id integer not null primary key,
			firstname varchar(256),
			lastname varchar(256),
			nickname varchar(256),
			logincount integer not null default 0,
			logindate timestamp with time zone,
			logoutdate timestamp with time zone,
			user_info jsonb,
			generation integer not null default 10,
			jetelina_delete_flg integer default 0
		);
	"""

	conn = open_connection()
	try
		execute(conn, create_jetelina_user_table_str)
	catch err
		JLog.writetoLogfile("PgDBController.create_jetelina_user_table() error: $err")
	finally
		close_connection(conn)
	end
end

"""
function userRegist(username::String)

	register a new user
	
# Arguments
- `username::String`:  user name. this data sets in as 'login','firstname' and 'lastname' at once.
- return::boolean: success->true  fail->false
"""
function userRegist(firstname::String, lastname::String)
	if !checkTheRoll("usermanage")
		return json(Dict("result" => false, "message from Jetelina" => "you do not have the authority yet, sorry"))
	end

	ret = ""
	jmsg::String = string("compliment me!")

	user_id = getJetelinaSequenceNumber(2)
	existentuserdata = getUserData(JSession.get()[1])
	j = existentuserdata["Jetelina"]
	parentGeneration = j[1][8]
	thisuserGeneration = parentGeneration + 1 # to make easy understand
	insert_basic_st = """
		insert into jetelina_user_table (user_id,firstname,lastname,generation) values($user_id,'$firstname','$lastname','$thisuserGeneration');
	"""

	inviterId = JSession.get()[2]
	registerDate = Dates.format(now(), "yyyy-mm-dd HH:MM:SS")

	insert_additional_st = """
		update jetelina_user_table set user_info = '{"register_date":"$registerDate","inviter":$inviterId}' where user_id=$user_id;
	"""

	conn = open_connection()
	try
		execute(conn, insert_basic_st)
		execute(conn, insert_additional_st)
		ret = json(Dict("result" => true, "message from Jetelina" => jmsg))
	catch err
		ret = json(Dict("result" => false, "username" => "$username", "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.userRegist() with $username error : $err")
	finally
		close_connection(conn)
	end

	return ret
end
"""
function getUserData(s::String)

	get jetelina user data by ordering 's'.
	this function is just calling chkUserExisence(), because wanna the function with name 'getUserdata'

# Arguments
- `s::String`:  user information. login account or first name or last name.
- return: success -> user data in Dict, fail -> ""		
"""
function getUserData(s::String)
	return chkUserExistence(s)
end
"""
function chkUserExistence(s::String)

	pre login, check the ordered user in jetelina_user_table or not
	search only alive user (jetelina_delete_flg=0)
	resume to refUserAttribute() if existed.
	the return type has cahnged because it is easier to check the parameters in PostDataController than json form. 
	
# Arguments
- `s::String`:  user information. login account or first name or last name.
- return: success -> user data in Dict, fail -> ""
"""
function chkUserExistence(s::String)
	ret = ""
	u::String = s
	jmsg::String = string("compliment me!")

	if contains(s, " ")
		ss = split(s, " ")
		u = ss[1]
	end

	#===
	sql = """   
	SELECT
		user_id,
		login,
		firstname,
		lastname,
		nickname,
		logincount,
		logindate,
		user_level,
		familiar_index
	from jetelina_user_table
	where (jetelina_delete_flg=0)and((login = '$u')or(firstname='$u')or(lastname='$u'));
	"""
	===#

	sql = """   
	SELECT
		user_id,
		firstname,
		lastname,
		nickname,
		logincount,
		logindate,
		logoutdate,
		generation
	from jetelina_user_table
	where (jetelina_delete_flg=0)and((nickname = '$u')or(firstname='$u')or(lastname='$u'));
	"""

	conn = open_connection()
	try
		df = DataFrame(columntable(LibPQ.execute(conn, sql)))
		#		ret = json(Dict("result" => true, "Jetelina" => copy.(eachrow(df)), "message from Jetelina" => jmsg))
		ret = Dict("result" => true, "Jetelina" => copy.(eachrow(df)), "message from Jetelina" => jmsg)

		#==
			Tips:
				every expression is fine, but take care the data type
				@info "user id 1 " df[:, :user_id] typeof(df[:,:user_id])  -> Vector{Union{Missing,Int}}
				@info "user id 2 " df[:, :user_id][1] typeof(df[:,:user_id][1])  -> Int
				@info "user id 3 " df.user_id typeof(df.user_id) -> Vector{Union{Missing,Int}}
		==#
		updateUserLoginData(df.user_id[1])
	catch err
		#		ret = json(Dict("result" => false, "errmsg" => "$err"))
		ret = Dict("result" => false, "errmsg" => "$err")
		JLog.writetoLogfile("PgDBController.chkUserExistence() with $s error : $err")
	finally
		close_connection(conn)
	end

	return ret
end
"""
function getUserInfoKeys(uid::Integer)

	get "user_info" column key data.
	"user_info" columns is json fromat. Indeed DataFrame() hard to handle this type, because
	in chkUserExisence() has many rows due to the keys, thus this function is separated from 
	chkUserExisence().

# Arguments
- `uid::Integer`: expect user_id
- return: success -> user data in json or DataFrame, fail -> ""
"""
function getUserInfoKeys(uid::Integer)
	ret = ""
	jmsg::String = string("compliment me!")

	sql = """   
	SELECT
		jsonb_object_keys (user_info) as user_info
	from jetelina_user_table
	where user_id=$uid;
	"""
	conn = open_connection()
	try
		df = DataFrame(columntable(LibPQ.execute(conn, sql)))
		ret = json(Dict("result" => true, "Jetelina" => copy.(eachrow(df)), "message from Jetelina" => jmsg))
	catch err
		ret = json(Dict("result" => false, "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.getUserInfoKeys() with $s error : $err")
	finally
		close_connection(conn)
	end

	return ret
end
"""
function refUserAttribute(uid::Integer,key::String,val)

	inquiring user_info data 
	
# Arguments
- `uid::Integer`: expect user_id
- `key::String`: key name in user_info json data
- `val`:  user input data. not sure the data type. String or Integer or something else
- `rettype::Integer`: return data type. 0->json 1->DataFrame 
- return: success -> user data in json or DataFrame, fail -> ""
"""
function refUserAttribute(uid::Integer, key::String, val, rettype::Integer)
	ret = ""
	result = false
	jmsg::String = string("compliment me!")

	#===
		Tips:
			search jsonb data here, it possibly contains some data in it,
			thus using 'like' sentence.
	===#
	sql = """   
	SELECT
		user_id, user_info -> '$key' as u_info_$key
	from jetelina_user_table
	where (user_id=$uid)and(user_info->>'$key' like '%$val%')
	"""
	conn = open_connection()
	try
		df = DataFrame(columntable(LibPQ.execute(conn, sql)))
		if 0 < nrow(df)
			# match the info
			result = true
		end

		if rettype == 0
			ret = json(Dict("result" => result, "Jetelina" => copy.(eachrow(df)), "message from Jetelina" => jmsg))
		else
			ret = df
		end
	catch err
		ret = json(Dict("result" => false, "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.refUserAttribute() with user $uid $key->$val error : $err")
	finally
		close_connection(conn)
	end

	return ret
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
	ret = ""

	# get existing user info data
	df = refUserAttribute(uid, key, value, 1)
	# append new value data to old one
	if 0 < nrow(df)
		value = string(df[:, :2], ',', value)
	end

	#===
		Tips:
			in the case of updating JSONB data type, the data is added at the tail if it were not existing.
			then do not need the hit or swing-miss by using LibPQ.num_affected_rows() alike in executeApi().
	===#
	sql = """
	update jetelina_user_table set
		user_info = jsonb_set(user_info,'{$key}','"$value"')
		where user_id=$uid;
	"""
	conn = open_connection()
	try
		execute(conn, sql)

		jmsg = """I have memorized your new $key, lucky knowing you more."""
		ret = json(Dict("result" => true, "Jetelina" => "[{}]", "message from Jetelina" => jmsg))
	catch err
		ret = json(Dict("result" => false, "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.updateUserInfo() with user $uid $key->$val error : $err")
	finally
		close_connection(conn)
	end

	return ret
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
	ret = ""
	set_str::String = ""

	if isa(value, String)
		set_str = """ $key='$value' """
	else
		set_str = """ $key=$value """
	end

	sql = """
	update jetelina_user_table set
		$set_str
		where user_id=$uid;
	"""
	conn = open_connection()
	try
		execute(conn, sql)

		jmsg = """He he, you are counted up in me."""
		ret = json(Dict("result" => true, "Jetelina" => "[{}]", "message from Jetelina" => jmsg))
	catch err
		ret = json(Dict("result" => false, "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.updateUserData() with user $uid $key->$val error : $err")
	finally
		close_connection(conn)
	end

	return ret
end
"""
function updateUserLoginData(uid::Integer)

	update user login data if it succeeded to login

# Arguments
- `uid::Integer`: expect user_id
- return: success -> true, fail -> error message
"""
function updateUserLoginData(uid::Integer)
	ret = true
	conn = open_connection()
	try
		#===
			Tips:
				logincount should be counted up only once in a day.
				complogindate is compare day number between logindate and current date with using cast(), this result retuns day number.
				then look at df[:,1][1], because df is Vector{Union{Missing, Int32}}.
		===#
		complogindate = """
			select cast(logindate as date) - cast(now() as date) from jetelina_user_table where user_id=$uid;
		"""

		df = DataFrame(columntable(LibPQ.execute(conn, complogindate)))
		if !ismissing(df[:, 1][1])
			if df[:, 1][1] == 0
				# update only logindate because multi login at same date
				column_str = """ logindate=now() """
			else
				# count up loginaccount
				column_str = """ logincount=logincount+1,logindate=now() """
			end
		else
			# very first login case
			column_str = """ logincount=logincount+1,logindate=now() """
		end

		sql = """
			update jetelina_user_table set
				$column_str
				where user_id=$uid;
		"""

		execute(conn, sql)

	catch err
		ret = false
		JLog.writetoLogfile("PgDBController.updateUserLoginData() with user $uid error : $err")
	finally
		close_connection(conn)
	end

	return ret
end
"""
function deleteUserAccount(uid::Integer)

	user delete, but not physical deleting, set jetelina_delete_flg to 1. 

# Arguments
- `uid::Integer`: expect user_id
- return: success -> true, fail -> error message
"""
function deleteUserAccount(uid::Integer)
	ret = ""

	sql = """
	update jetelina_user_table set
		jetelina_delete_flg=1
		where user_id=$uid;
	"""
	conn = open_connection()
	try
		execute(conn, sql)

		jmsg = """See you someday"""
		ret = json(Dict("result" => true, "Jetelina" => "[{}]", "message from Jetelina" => jmsg))
	catch err
		ret = json(Dict("result" => false, "errmsg" => "$err"))
		JLog.writetoLogfile("PgDBController.deleteUserAccount() with user $uid $key->$val error : $err")
	finally
		close_connection(conn)
	end

	return ret
end
"""
function checkTheRoll(roll::String)

	check the ordered user's authority in order to 'roll'.
  	   e.g. roll = 'delete', this user is required login count more than 5 in case of its generation is 0.
	
	generation |           login count
			   | create |  delete | user management
		0      |    1   |    1    |      1
		1      |    1   |    5    |      8
		2      |    1   |   x3    |     x3
		3      |    1   |   x4    |     x4
		
# Arguments
- `roll::String`: target authority
- return: have authority -> true, does not have -> false
"""
function checkTheRoll(roll::String)
	uid = JSession.get()[2]
	ret::Bool = false

	sql = """
		select logincount, generation from jetelina_user_table 
		where (jetelina_delete_flg=0) and (user_id=$uid);
	"""
	conn = open_connection()
	try
		df = DataFrame(columntable(LibPQ.execute(conn, sql)))
		if !ismissing(df[:, :generation][1]) && !ismissing(df[:, :logincount][1])
			generation = df[:, :generation][1]
			logincount = df[:, :logincount][1]

			delete_base_number = 5 # this number is for basic login count number ref in function description
			usermanage_base_number = 8 #       〃
			base_number::Integer = 0

			if roll == "delete"
				base_number = delete_base_number
			elseif roll == "usermanage"
				base_number = usermanage_base_number
			end

			if generation == 1
				if base_number <= logincount
					ret = true
				end
			elseif generation == 2
				if base_number * 3 <= logincount  # ref in function description about '3' number
					ret = true
				end
			elseif generation == 3
				if base_number * 4 <= logincount # ref in function description about '4' number
					ret = true
				end
			else
				# case of generation = 0	
			end
		end
		
	catch err
		JLog.writetoLogfile("PgDBController.deleteUserAccount() with user $uid $key->$val error : $err")
	finally
		close_connection(conn)
	end

	return ret
end
end
