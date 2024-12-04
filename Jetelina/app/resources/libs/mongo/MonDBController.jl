"""
module: MonDBController

Author: Ono keiji

Description:
	DB controller for MongoDB

functions
	open_connection() open connection to the DB.
    open_collection(jcollection::String) open "collection" to the DB.
	close_connection()  close the DB connection, but attention...
	dataInsertFromJson(fname::String, collectionname::String) insert csv file data ordered by 'fname' into table. the table name is the csv file name.

    getCollectionList(jcollection::String,s::String) get all 'document' in 'jcollection'.
	executeApi(jcollection::String,json_d::Dict,target_api::DataFrame) execute API order by json data

    

    prepareDbEnvironment(mode::String) database connection checking, and initializing database if needed
"""
#===
        Tips:
            words against RDBMS

              |   RDBMS   |  MongoDB  |
              | database  | database  |
              | table     | collection|
              | row       | document  |
              | column    | field     |
===#
module MonDBController

using Genie, Genie.Renderer, Genie.Renderer.Json
using CSV, Mongoc, DataFrames, IterTools, Tables, Dates
using Jetelina.JFiles, Jetelina.JLog, Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.JMessage, Jetelina.JSession
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

include("MonDataTypeList.jl")
include("MonSQLSentenceManager.jl")

export open_connection, open_collection, close_connection, dataInsertFromJson, getCollectionList, executeApi, prepareDbEnvironment

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
- `collectionname: String`: ordered collection name
- return: boolean: true -> success, false -> get fail
"""
function dataInsertFromJson(fname::String, collectionname::String)
    result::Bool = false
    ret = ""
    jmsg::String = string("compliment me!")

    #===
        Tips:
            should set the parameter in open_collection() in order to change the collection.
            but the collection is fixed in the earliest version.
            will may need to modify parameters in dataInsertFromJson() as well if would be changed by ordering.  
    ===#
    collection = open_collection(collectionname)

    # いっぺんに処理する方法
    #bsons = Mongoc.read_bson_from_json(fname)
    #result = append!(collection,bsons)

    # 一つづつ処理する方法
    jdata = Mongoc.BSONJSONReader(fname)
    for bson in jdata
        # data insert
        result = push!(collection, bson)
        if result
            # create api 
            _createApis()
        else
            break
        end
    end

    if result
        ret = json(Dict("result" => true, "filename" => "$fname", "message from Jetelina" => jmsg))
    else
        ret = json(Dict("result" => false, "filename" => "$fname", "message from Jetelina" => "no way"))
    end

    return ret
end

function _createApis()
            # bson毎にapiを作る
            insert_str = MonSQLSentenceManager.createApiInsertSentence()
            if (insert_str != "")
                ApiSqlListManager.writeTolist(insert_str, "", "", "mongodb")
            end

            #===
                Tips:
                    update and select(find) works with a plane json format data that is provided by an user.
                    therefore an argument in each functions(createApi...) are to be empty.
            ===#
            # update (set)
            update_str = MonSQLSentenceManager.createApiUpdateSentence("")
            if (update_str != "")
                    ApiSqlListManager.writeTolist(update_str, "", "", "mongodb")
            end

            # select (find)
            select_str = MonSQLSentenceManager.createApiSelectSentence("")
            if (select_str != "")
                ApiSqlListManager.writeTolist(select_str, "", "", "mongodb")
            end
end
"""
function getCollectionList(jcollection::String, s::String)

    get all 'document' in 'jcollection'.

# Arguments
- `jcollection:String`: collection name
- `s:String`: 'json' -> required JSON form to return
			'dataframe' -> required DataFrames form to return
- return: document list
"""
function getCollectionList(jcollection::String, s::String)
    jmsg::String = string("compliment me!")
    keyword::String = "j_table"
    docArr::Array = []

    documents = open_collection(jcollection)

    for j_table in documents
        push!(docArr, j_table[keyword])
    end

    df = DataFrame(j_table=docArr)
    if s == "json"
        return json(Dict("result" => true, "Jetelina" => copy.(eachrow(reverse(df))), "message from Jetelina" => jmsg))
    elseif s == "dataframe"
        return df
    end
end
"""
function executeApi(json_d::Dict,target_api::DataFrame)

	execute API order by json data
	this function is a parent function that calls _executeApi()
	determine the target then executs it in _executeApi()

# Arguments
- `jcollection:String`: collection name
- `json_d::Dict`:  json raw data, uncertain data type        
- `target_api::DataFrame`: a part of api/sql DataFrame data        
- return: insert/update/delete -> true/false
		select               -> json format data
		error                -> false
"""
function executeApi(j_collection::String,json_d::Dict, target_api::DataFrame)
    return _executeApi(j_collection,json_d, target_api)
end
"""
function _executeApi(j_collection::String, apino::String, target_api::DataFrame)

	execute API with creating SQL sentence
	this is a private function that is called by executeApi()

# Arguments
- `jcollection:String`: collection name
- `apino::String`:  apino
- `target_api::DataFrame`: target redis api dataframe        
- return: insert/update/delete -> true/false
		select               -> json format data
		error                -> false
"""
function _executeApi(json_d::Dict, target_api::DataFrame)
    apino = json_d["apino"]
    #    @info "redis exe " apino 
    #    println(dfRedis)
    ret = ""
    jmsg::String = string("compliment me!")

    collection = open_collection("")
    bson = Mongoc.BSON(jsond_d)

    if startswith(apino, "js")
        # find
        finddata_bson::Array = []
        finddata_json::Array = []
        doc = Mongoc.find(collection,bson)
        if isnothing(doc)
            for d in doc
                push!(finddata_bson,d)
            end
        end

        if 0<length(finddata_bson)
            for d in finddata_bson
                jd = Mongoc.as_json(finddata_bson)
                push!(finddata_json,jd)
            end
        end

        if 0<length(finddata_json)
            ret = json(Dict("result" => true, "Jetelina" => [finddata_json], "message from Jetelina" => jmsg))
        else
            ret = json(Dict("result" => false, "Jetelina" => "[{}]", "message from Jetelina" => "not found"))
        end
    elseif startswith(apino, "ju")
        ud_j = json["update"]
        ud_t = json["tagete"]
        target_bson = Mongoc.BSON(ud_t)
        finddata_bson = Mongoc.find_one(collection,target_bson)
        ud_j = Mongoc.BSON("""{"\$set": $ud_t}""")
        ret = Mongoc.update_one(collection, finddata_bson, ud_j)
        if 0<ret["modifiedCount"]
            ret = json(Dict("result" => true, "Jetelina" => "[{}]", "message from Jetelina" => jmsg))
        else
            # what happend?
        end
    elseif startswith(apino, "ji")
        if isnothing(Mongoc.find_one(collection,bson))
            # new document
            push!(collection,bson)
        else
            # duplication, then nothing to do
        end

        #===
            Tips:
                after data insertion, check it once then create APIs sentences.
                because the result of push!() is too difficult to judge the succession.

        # create new apis

        _createApis(j_table)
        ===#


#===
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
            ret = json(Dict("result" => false, "Jetelina" => "[{}]", "message from Jetelina" => "failed set $v in $k sorry", "errnum" => "$errnum"))
        end
===#
    end

    return ret
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
        open_connection()
        close_connection() # dummy :p
        return true, ""
    catch err
        errnum = JLog.getLogHash()
        JLog.writetoLogfile("[errnum:$errnum] MonDBController.prepareDbEnvironment() error : $err")
        return ret, errnum
    finally
    end
end

end
