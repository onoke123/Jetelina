"""
module: RsDBController

Author: Ono keiji

Description:
	DB controller for PostgreSQL

functions
	open_connection() open connection to the DB.
	close_connection(conn::Redis.Connection)  close the DB connection
	dataInsertFromCSV(fname::String) insert csv file data ordered by 'fname' into table. the table name is the csv file name.
	getKeyList(s::String) get all key name
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

export open_connection, close_connection, dataInsertFromCSV, getKeyList, executeApi

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
function dataInsertFromCSV(fname::String)

	insert csv file data ordered by 'fname' into table. the table name is the csv file name.

    Attention:
        not coding yet, maybe near future, ignore this function.

# Arguments
- `fname: String`: csv file name
- return: boolean: true -> success, false -> get fail
"""
function dataInsertFromCSV(fname::String)
    @info "fname " fname
    ret = ""
#	redisdbname = "default" # this is temporary dummy name, indeed it's ok what a name
    jmsg::String = string("compliment me!")
#    tablename_arr::Vector{String} = []

    df = DataFrame(CSV.File(fname))
    rename!(lowercase, df)
#    push!(tablename_arr, redisdbname)

    if(0<nrow(df))
    #===
            Tips:
                to make matching with ApiSql..writeToList(), the secound parameter is to be 'key_arr' and
                it is contained the key name instead of table name in RDBMS.
        ===#
		for i ∈ 1:nrow(df)
            key_arr::Vector{String} = []
            #===
                Caution:
                    in fact, insert_str is enough only one, but in the loop because of 
                    using 'apino'
            ===#
            insert_str = RsSQLSentenceManager.createApiInsertSentence()
            if(insert_str != "")
                ApiSqlListManager.writeTolist(insert_str, "", key_arr, "redis")
            end

            push!(key_arr,df.key[i])
            # update (set)
            update_str = RsSQLSentenceManager.createApiUpdateSentence(df.key[i])
            if(update_str != "")
                if(set(df.key[i],df.value[i]))
                    ApiSqlListManager.writeTolist(update_str, "", key_arr, "redis")
                end
            end

            # select (get)
            select_str = RsSQLSentenceManager.createApiSelectSentence(df.key[i])
            if(select_str != "")
                ApiSqlListManager.writeTolist(select_str,"", key_arr, "redis")
            end
        end

        ret = json(Dict("result" => true, "filename" => "$fname", "message from Jetelina" => jmsg))
    else
        ret = json(Dict("result" => false, "filename" => "$fname", "message from Jetelina" => "no way"))
    end

    return ret
end
"""
function getKeyList(s::String)

    Caution:
        return json using 'tablename' instead of 'keys' because of matching I/F in js function.

	get all keys name

# Arguments
- `s:String`: 'json' -> required JSON form to return
			'dataframe' -> required DataFrames form to return
- return: table list in json or DataFrame

"""
function getKeyList(s::String)
    i::Int = 0
    n::Int = 10000
    keysArr::Array = []
    valueArr::Array = []
    jmsg::String = string("compliment me!")

    keys = simpleScan(i, n)
    if(keys[1] == 0)
        for i ∈ 1:length(keys[2])
            push!(keysArr,"tablename")
            push!(valueArr,keys[2][i])
        end

        df = DataFrame(keysArr=valueArr)
        if s == "json"
            return json(Dict("result" => true, "Jetelina" => copy.(eachrow(df)), "message from Jetelina" => jmsg))
        elseif s == "dataframe"
            return df
        end
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
#    ret = ""
#    sql_str = RsSQLSentenceManager.createExecutionSqlSentence(json_d, target_api)
#    if 0 < length(sql_str)
        ret = _executeApi(json_d["apino"], target_api)
#    end

    return ret
end
"""
function _executeApi(apino::String,sql_str::String)

	execute API with creating SQL sentence
	this is a private function that is called by executeApi()

# Arguments
- `apino::String`:  apino
- `dfRedis::DataFrame`: target redis api dataframe        
- return: insert/update/delete -> true/false
		select               -> json format data
		error                -> false
"""
function _executeApi(apino::String, dfRedis::DataFrame)
    ret = ""
    jmsg::String = string("compliment me!")

        if startswith(apino, "js")
            # get 
            p = split(redisSql[:,:sql][1], ':') # redisSql[:,:sql][1] -> get:<key>
            v = get(p[2])
            df = DataFrame(key=p[2],value=v)
            ret = json(Dict("result" => true, "Jetelina" => copy.(eachrow(df)), "message from Jetelina" => jmsg))
        elseif startswith(apino, "ji")
            # set
            p = split(redisSql[:,:sql][1], ':') # redisSql[:,:sql][1] -> set:<key>:<value>
            r = set(p[2],p[3])
            if(r)
                #===
                    Attention:
                        'ji***' is for registring a new key/value data.
                        therefore need to create a new api at here.
                ===#
                update_str = RsSQLSentenceManager.createApiUpdateSentence(p[2])
                if(update_str != "")
                    ApiSqlListManager.writeTolist(update_str, "", key_arr, "redis")
                end

                ret = json(Dict("result" => true, "Jetelina" => "[{}]", "message from Jetelina" => jmsg))
            else
                ret = json(Dict("result" => false, "Jetelina" => "[{}]", "message from Jetelina" => value))
            end
        end

    return ret
end
"""
function set(k,v)

	set 'k'='v' in name=value style in redis

# Arguments
- `k:String`: name
- `v:Any`: value
- return: boolean:  success -> true::boolean, fail -> err::String
"""
function set(k, v)
    conn = open_connection()
    try
        Redis.set(conn, k, v)
        return true
    catch err
        JLog.writetoLogfile("RsDBController.set() error: $err")
        return err
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
