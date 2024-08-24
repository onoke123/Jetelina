"""
module: RsDBController

Author: Ono keiji

Description:
	DB controller for PostgreSQL

functions
	open_connection() open connection to the DB.
	close_connection(conn::Redis.Connection)  close the DB connection
	getTableList(s::String) get all table name from public 'schemaname'
	dataInsertFromCSV(fname::String) insert csv file data ordered by 'fname' into table. the table name is the csv file name.
	getColumns(tableName::String) get columns name of ordereing table.
	executeApi(json_d::Dict,target_api::DataFrame) execute API order by json data
	_executeApi(apino::String, sql_str::String) execute API with creating SQL sentence,this is a private function that is called by executeApi()
    set(k,v) set 'k'='v' in name=value style in redis
    get(k) get value data in redis in order to match name 'k'
    matchingScan(i,k) scan, indeed searching, data to find matching from 'i' cursor position with 'k' string
    simpleScan(i,n) scan, indeed searching, data from 'i' cursor position order by 'n' counts.
    """
module RsDBController

using Genie, Genie.Renderer, Genie.Renderer.Json
using CSV, Redis, DataFrames, IterTools, Tables, Dates
using Jetelina.JFiles, Jetelina.JLog, Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.JMessage, Jetelina.JSession
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

include("RsDataTypeList.jl")
include("RsSQLSentenceManager.jl")

export open_connection, close_connection, getTableList, dataInsertFromCSV, getColumns,
    executeApi

"""
function open_connection()

	open connection to the DB.
	connection parameters are set by global variables.

# Arguments
- return: Redis.Connection object
"""
function open_connection()
    rhost = string(j_config.JC["redis_host"])
    rport = parse(Int, j_config.JC["redis_port"])
    rdb = parse(Int, j_config.JC["redis_db"])
    rpassword = string(j_config.JC["redis_password"])

    return conn = Redis.RedisConnection(host="$rhost", port=rport, password="$rpassword", db=rdb)
    #return conn = Redis.RedisConnection()
end

"""
function close_connection(conn::Redis.Connection)

	close the DB connection

# Arguments
- `conn:Redis.Connection`: Redis.Connection object
"""
function close_connection(conn::Redis.RedisConnection)
    Redis.disconnect(conn)
end
"""
function getTableList(s::String)

    Caution:
        here 'table' meaning is indeed 'db' in redis.
        to create a sense of unity with RDMS funcs, 'db' calls 'table' here.

	get all table name

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

    Caution:
        here 'table' meaning is indeed 'db' in redis.
        to create a sense of unity with RDMS funcs, 'db' calls 'table' here.

        and Redis is an experimental imprementation in jetleina ver.2, thus 'db' is only one that is called and
        defined as 'defalut".:D

	get table list then put it into DataFrame object. this is a private function, but can access from others

# Arguments
- return: DataFrame object. empty if got fail.
"""
function _getTableList()
    df = DataFrame()
#    conn = open_connection()
    try
        df = DataFrames(tablename="default")
#        df = DataFrame(columntable(Redis.execute(conn, table_str)))
        # do not include 'jetelina_table_manager and usertable in the return
#        DataFrames.filter!(row -> row.tablename != "jetelina_table_manager" && row.tablename != "jetelina_user_table", df)
    catch err
        JLog.writetoLogfile("RsDBController._getTableList() error: $err")
        return DataFrame() # return empty DataFrame if got fail
    finally
#        close_connection(conn)
    end

    return df
end

"""
function dataInsertFromCSV(fname::String)

	insert csv file data ordered by 'fname' into table. the table name is the csv file name.

    Attention:
        not coding yet, maybe near future, ignore this function.

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
    column_type_string = Array{Union{Nothing,String}}(nothing, length(column_name)) # using for creating table
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
        column_type_string[i] = RsDataTypeList.getDataType(string(column_type[i]))
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
        @info "RsDBController.dataInsertFromCSV() col str to create table: " column_str
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
        JLog.writetoLogfile("RsDBController.dataInsertFromCSV() with $fname error : $err")
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
    df0 = DataFrame(columntable(Redis.execute(conn, sql)))
    rename!(lowercase, df0)
    cols = map(x -> x, names(df0))
    select!(df, cols)

    # create rows
    row_strings = imap(eachrow(df)) do row
        join((ismissing(x) ? "null" : x for x in row), ",") * "\n"
    end

    copyin = Redis.CopyIn("COPY $tableName FROM STDIN (FORMAT CSV);", row_strings)
    try
        execute(conn, copyin)
        ret = json(Dict("result" => true, "filename" => "$fname", "message from Jetelina" => jmsg))
    catch err
        #            println(err)
        ret = json(Dict("result" => false, "filename" => "$fname", "errmsg" => "$err"))
        JLog.writetoLogfile("RsDBController.dataInsertFromCSV() with $fname error : $err")
        return ret
    finally
        # ok. close the connection finally
        close_connection(conn)
    end
    #===
    		Tips:
    		cols(see above) is ["id", "name", "sex", "age", "ave", "jetelina_delete_flg"], so can use it when
    		wanna use column name, but need to judge the data type both the case of 'insert' and 'update', 
    		that why do not use cols here. writing select sentence is done in RsSQLSentenceManager.createApiSelectSentence(). 
    	===#
    push!(tablename_arr, tableName)
    insert_str = RsSQLSentenceManager.createApiInsertSentence(tableName, insert_column_str, insert_data_str)
    ApiSqlListManager.writeTolist(insert_str, "", tablename_arr, getJetelinaSequenceNumber(1), "redis")

    # update
    update_str = RsSQLSentenceManager.createApiUpdateSentence(tableName, update_str)
    ApiSqlListManager.writeTolist(update_str[1], update_str[2], tablename_arr, getJetelinaSequenceNumber(1), "redis")

    # delete
    delete_str = RsSQLSentenceManager.createApiDeleteSentence(tableName)
    ApiSqlListManager.writeTolist(delete_str[1], delete_str[2], tablename_arr, getJetelinaSequenceNumber(1), "redis")

    if isempty(df_tl)
        # manage to jetelina_table_manager
        insert2JetelinaTableManager(tableName, names(df0))
    end

    return ret
end

"""
function getColumns(tableName::String)

    Caution:
        here 'columns' meaning is indeed 'keys' in redis.
        to create a sense of unity with RDMS funcs, 'keys' calls 'columns' here.

	get columns name of ordereing table.

# Arguments
- `tableName: String`: DB table name
- return: String: in success -> column data in json, in fail -> ""
"""
function getColumns(type::String,key::String)
    ret::tuple = ""
    jmsg::String = string("compliment me!")
    cursor::Int = 0
    limitnumber::Int = 10000

    if(type == "all")
        ret = simpleScan(cursor,limitnumber)
    elseif(type == "match")
        ret = matchingScan(cursor,key)
    end

    if(!nothing(ret[2]))
        return ret[2]
    else
        return false
    end
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
    sql_str = RsSQLSentenceManager.createExecutionSqlSentence(json_d, target_api)
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
        sql_ret = Redis.execute(conn, sql_str)
        #===
        			Tips:
        				case in insert/update/delete, we cannot see if it got success or not by .execute().
        				using .num_affected_rows() to see the worth.
        					in insert -> 0: normal end, the fault is caught in 'catch'
        					in update/delete -> 0: swing and miss
        									 -> 1: hit the ball
        		===#
        affected_ret = Redis.num_affected_rows(sql_ret)
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
        JLog.writetoLogfile("RsDBController.executeApi() with $apino : $sql_str error : $err")
        ret = json(Dict("result" => false, "apino" => "$apino", "errmsg" => "$err"))
    finally
        # close the connection finally
        close_connection(conn)
    end

    return ret
end
"""
function set(k,v)

	set 'k'='v' in name=value style in redis

# Arguments
- `k:String`: name
- `v:Any`: value
- return: boolean:  true -> success, faluse -> error
"""
function set(k, v)
    conn = open_connection()
    try
        Redis.set(conn, k, v)
        return true
    catch err
        JLog.writetoLogfile("RsDBController.set() error: $err")
        return false
    finally
        close_connection(conn)
    end
end
"""
function get(k)

	get value data in redis in order to match name 'k'

# Arguments
- `k:String`: target matching name
- return: String:  value in redis in matching key name
"""
function get(k)
    conn = open_connection()
    try
        v = Redis.get(conn, k)
        return v
    catch err
        @info err
        JLog.writetoLogfile("RsDBController.get() error: $err")
        return false
    finally
        close_connection(conn)
    end
end
"""
function matchingScan(i,k)

	scan, indeed searching, data to find matching from 'i' cursor position with 'k' string

# Arguments
- `i:Int`: cursor position number, default 0
- `k:String`: target scan string
- return: Tuple(number,AbstractString Vector):  matching key name array in redis
"""
function matchingScan(i, k)
    conn = open_connection()
    try
        v = Redis.scan(conn, i, "match", string(k, '*'))
        return v
    catch err
        @info err
        JLog.writetoLogfile("RsDBController.matchingScan() error: $err")
        return false
    finally
        close_connection(conn)
    end
end
"""
function simpleScan(i,n)

	scan, indeed searching, data from 'i' cursor position order by 'n' counts.

# Arguments
- `i:Int`: cursor position number, default 0
- `n:Int`: scanning number at once
- return: Tuple(number,AbstractString Vector):  key name array in redis
"""
function simpleScan(i, n)
    conn = open_connection()
    try
        v = Redis.scan(conn, i, :count, n)
        return v
    catch err
        @info err
        JLog.writetoLogfile("RsDBController.simpleScan() error: $err")
        return false
    finally
        close_connection(conn)
    end
end
end
