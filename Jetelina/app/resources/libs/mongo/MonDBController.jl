"""
module: MonDBController

Author: Ono keiji

Description:
	DB controller for MongoDB

functions
	open_connection() open connection to the DB.
    open_collection(jcollection::String) open "collection" to the DB.
	close_connection()  close the DB connection, but attention...
	dataInsertFromJson(fname::String) insert csv file data ordered by 'fname' into table. the table name is the csv file name.
	getKeyList(s::String) get all key name
	executeApi(json_d::Dict,target_api::DataFrame) execute API order by json data
	_executeApi(apino::String, sql_str::String) execute API with creating SQL sentence,this is a private function that is called by executeApi()
    set(k,v) set 'k'='v' in name=value style in redis
    get(k) get value data in redis in order to match name 'k'
    matchingScan(i,k) scan, indeed searching, data to find matching from 'i' cursor position with 'k' string
    simpleScan(i,n) scan, indeed searching, data from 'i' cursor position order by 'n' counts.
    prepareDbEnvironment(mode::String) database connection checking, and initializing database if needed
"""
module MonDBController

using Genie, Genie.Renderer, Genie.Renderer.Json
using CSV, Mongoc, DataFrames, IterTools, Tables, Dates
using Jetelina.JFiles, Jetelina.JLog, Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.JMessage, Jetelina.JSession
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

include("MonDataTypeList.jl")
include("MonSQLSentenceManager.jl")

export open_connection, open_collection, close_connection, dataInsertFromJson, getKeyList, executeApi, prepareDbEnvironment

"""
function open_connection()

	open connection to the DB.
	connection parameters are set by global variables.

# Arguments
- return: Mongoc.Client object
"""
function open_connection()
    host = string(j_config.JC["mongodb_host"])
    port = parse(Int, j_config.JC["mongodb_port"])
    db = string(j_config.JC["mongodb_dbname"])
    user = string(j_config.JC["mongodb_user"])
    password = string(j_config.JC["mongodb_password"])

    connectionstr::String = ""

    if user == "" || password == ""
        connectionstr = """mongodb://$host:$port"""
    else
        connectionstr = """mongodb://$user:$password@$host/?authSource=admin"""
    end

    client = Mongoc.Client(connectionstr)
    return client[db] 
end
"""
function open_collection(jcollection::String)

	open "collection" to the DB.
    this function is for setting "collection" in Mongoc.Client.

# Arguments
- `jcollection: String`: Monogdb collection name
- return: Mongoc.Client with setting collection
"""
function open_collection(jcollection::String)
    if isnothing(jcollection) || length(jcollection) == 0
        jcollection = string(j_config.JC["mongodb_collection"])
    end

    database = open_connection()
    return database[jcollection]
end
"""
function close_connection()

	Attention:
        this function is for preventing of misunderstanding.
        Mongoc module does not have a disconnect function, because the Client() has the function in it.
        Indeed there is finalizer() in Client() to disconnect the connection automatically when the connection has been focused out.
        this is very smart behavior but easy to misunderstand in how to disconnect, I think. Sometimes a programer likes to make clear its logic no matter what implicit definitions.
        therefore this close_connection() keeps alive in case you would feel unsafe, but not working.

"""
function close_connection()
    # empty :p
end
"""
function dataInsertFromJson(fname::String)

	insert json file data ordered by 'fname' into collection.

    Caution:
        regurate 1 collection , max 64 index(mean 64 json data) in this version.
        no check at size e.g. BSON size(max16mb). rely on user, this time. :)

# Arguments
- `fname: String`: json file name
- return: boolean: true -> success, false -> get fail
"""
function dataInsertFromJson(fname::String)
    result::Bool = false
    ret = ""
    jmsg::String = string("compliment me!")

    #===
        Tips:
            should set the parameter in open_collection() in order to change the collection.
            but the collection is fixed in the earliest version.
            will may need to modify parameters in dataInsertFromJson() as well if would be changed by ordering.  
    ===#    
    collection = open_collection("")

    # いっぺんに処理する方法
    #bsons = Mongoc.read_bson_from_json(fname)
    #result = append!(collection,bsons)

    # 一つづつ処理する方法
    jdata = Mongoc.BSONJSONReader(fname)
    for bson in jdata
        # data insert
        result = push!(collection,bson)
        if result
            # bson毎にapiを作る
            insert_str = MonSQLSentenceManager.createApiInsertSentence()
            if (insert_str != "")
                ApiSqlListManager.writeTolist(insert_str, "", key_arr, "mongo")
            end

            push!(key_arr, df.key[i])
            # update (set)
            update_str = MonSQLSentenceManager.createApiUpdateSentence()
            if (update_str != "")
                if (set(df.key[i], df.value[i])[1])
                    ApiSqlListManager.writeTolist(update_str, "", key_arr, "mongo")
                end
            end

            # select (get)
            select_str = MonSQLSentenceManager.createApiSelectSentence()
            if (select_str != "")
                ApiSqlListManager.writeTolist(select_str, "", key_arr, "mongo")
            end
        else
            break;
        end
    end

    if result            
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
    if (keys[1] == 0)
        for i ∈ 1:length(keys[2])
            #===
                Tips:
                    they said keys[2][i] is string type.
            ===#
            if keys[2][i] != ""
                push!(valueArr, keys[2][i])
            end
        end

        df = DataFrame(keysArr=valueArr)
        if s == "json"
            return json(Dict("result" => true, "Jetelina" => copy.(eachrow(reverse(df))), "message from Jetelina" => jmsg))
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
    return _executeApi(json_d, target_api)
end
"""
function _executeApi(apino::String, dfRedis::DataFrame)

	execute API with creating SQL sentence
	this is a private function that is called by executeApi()

# Arguments
- `apino::String`:  apino
- `dfRedis::DataFrame`: target redis api dataframe        
- return: insert/update/delete -> true/false
		select               -> json format data
		error                -> false
"""
function _executeApi(json_d::Dict, dfRedis::DataFrame)
    apino = json_d["apino"]
    #    @info "redis exe " apino 
    #    println(dfRedis)
    ret = ""
    jmsg::String = string("compliment me!")

    if startswith(apino, "js")
        # get 
        p = split(dfRedis[:, :sql][1], ':') # dfRedis[:,:sql][1] -> get:<key>
        r = get(p[2])
        if(r[1])
            v = r[2]
            df = DataFrame(key=p[2], value=v)
            ret = json(Dict("result" => true, "Jetelina" => copy.(eachrow(df)), "message from Jetelina" => jmsg))
        else
            err = "Oops got error something, oh my"
            errnum = r[2]
            ret = json(Dict("result" => false, "Jetelina" => "[{}]", "errmsg"=>"$err","errnum"=>"$errnum"))
        end
    elseif startswith(apino, "ju")
        v = json_d["key"]
        if !isnothing(v)
            p = split(dfRedis[:, :sql][1], ':') # dfRedis[:,:sql][1] -> get:<key>
            r = set(p[2], v)
            #                @info "redis set " p[2] v r
            if (r[1])
                ret = json(Dict("result" => true, "Jetelina" => "[{}]", "message from Jetelina" => jmsg))
            else
                k = p[2]
                errnum = r[2]
                ret = json(Dict("result" => false, "Jetelina" => "[{}]", "message from Jetelina" => "failed set $v in $k, sorry","errnum"=>"$errnum"))
            end
        else
            ret = json(Dict("result" => false, "Jetelina" => "[{}]", "message from Jetelina" => "failed set in $k because no value, look carefully more."))
        end
    elseif startswith(apino, "ji")
        ret_u::Tuple = (Bool, String)
        ret_s::Tuple = (Bool, String)
#        ret_u::String = ""
#        ret_s::String = ""
        k = lowercase(json_d["key1"])
        v = json_d["key2"]
        # set
        r = set(k, v)
        if (r[1])
            #===
                Attention:
                    'ji***' is for registring a new key/value data.
                    therefore need to create a new api 'ju***' and 'js***' at here.
            ===#
            update_str = MonSQLSentenceManager.createApiUpdateSentence(k)
            if (update_str != "")
                key_arr::Vector{String} = []
                push!(key_arr, k)
                ret_u = ApiSqlListManager.writeTolist(update_str, "", key_arr, "redis")

                select_str = MonSQLSentenceManager.createApiSelectSentence(k)
                if (select_str != "")
                    ret_s = ApiSqlListManager.writeTolist(select_str, "", key_arr, "redis")
                end
            end

            #===
                Caution:
                    i was wondering it was ok without looking at the result of writeTolist().
                    but maybe they would be succeed.
                    it was not a lottery, but confidence. :)
            ===#
            if ret_u[1] && ret_s[1]
                apino_u = ret_u[2]
                apino_s = ret_s[2]
                ret = json(Dict("result" => true, "Jetelina" => "[{}]", "apino" => ["$apino_u", "$apino_s"], "message from Jetelina" => jmsg))
            elseif ret_u[1]
                apino_u = ret_u[2]
                jmsg = "only update api has been created, select api is why?"
                ret = json(Dict("result" => true, "Jetelina" => "[{}]", "apino" => ["$apino_u", ""], "message from Jetelina" => jmsg))
            elseif ret_s[1]
                apino_s = ret_s[2]
                jmsg = "only select api has been created, update api is why?"
                ret = json(Dict("result" => true, "Jetelina" => "[{}]", "apino" => ["", "$apino_s"], "message from Jetelina" => jmsg))
            end
        else
            k = p[1]
            v = p[2]
            errnum = r[2]
            ret = json(Dict("result" => false, "Jetelina" => "[{}]", "message from Jetelina" => "failed set $v in $k sorry","errnum"=>"$errnum"))
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
- return: tuple(boolean,string):  success -> (true,""), fail -> (false,error number)
"""
function set(k, v)
    conn = open_connection()
    try
        Redis.set(conn, k, v)
        return true, ""
    catch err
        errnum = JLog.getLogHash()
        JLog.writetoLogfile("[errnum:$errnum] MonDBController.set() error: $err")
        return false, errnum
    finally
        close_connection(conn)
    end
end
"""
function get(k)

	get value data in redis in order to match name 'k'

# Arguments
- `k:String`: target matching name
- return: tuple(boolean,String): success->(true, value in redis in matching key name) false -> (false, error number)
"""
function get(k)
    conn = open_connection()
    try
        v = Redis.get(conn, k)
        return true, v
    catch err
        errnum = JLog.getLogHash()
        JLog.writetoLogfile("[errnum:$errnum] MonDBController.get() error: $err")
        return false, errnum
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
        JLog.writetoLogfile("MonDBController.matchingScan() error: $err")
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
        JLog.writetoLogfile("MonDBController.simpleScan() error: $err")
        return false
    finally
        close_connection(conn)
    end
end
"""
function prepareDbEnvironment()

	database connection checking, and initializing database if needed
		
# Arguments
- `mode::String`: 'init' -> initialize, others -> connection check
                  but this parameter does not have any meaning in here, 
                  just match with the same name function of mysql/postgresql. :p
- return: success -> true, fail -> false
"""
function prepareDbEnvironment(mode::String)
    ret::Bool = false
    try
        conn::Redis.RedisConnection = open_connection()
        close_connection(conn)
        return true, ""
    catch err
        errnum = JLog.getLogHash()
        JLog.writetoLogfile("[errnum:$errnum] MonDBController.prepareDbEnvironment() error : $err")
        return ret, errnum
    finally
    end
end

end
