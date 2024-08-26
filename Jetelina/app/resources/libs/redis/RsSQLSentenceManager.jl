"""
module: RsSQLSentenceManager

Author: Ono keiji

Description:
	DB controller for Redis

functions
	keyDuplicationCheck(nsql::String, subq::String)  confirm duplication, if 'nsql' exists in JC["sqllistfile"].but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 
	createApiInsertSentence(key::String,value::String)	create redis set sentence.
	createApiSelectSentence(key::String) create redis get sentence.
"""
module RsSQLSentenceManager

using DataFrames, StatsBase
using Genie, Genie.Requests, Genie.Renderer.Json
using Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.JMessage

JMessage.showModuleInCompiling(@__MODULE__)

export keyDuplicationCheck, createApiInsertSentence, createApiSelectSentence

"""
function keyDuplicationCheck(nsql::String)

	confirm duplication, if 'key' exists in JC["sqllistfile"].
	but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 

# Arguments
- `key::String`: sql sentence
- return::Bool : exist -> ture
				 not exist -> false
"""
function keyDuplicationCheck(str::String)
	ret::Bool = false
	#===
		Tips:
			ApiSql...readSql...()[1] contains true/false.
			ApiSql...readSql...()[2] contains dataframe list if [] is true, in the case of false is nothing.
	===#			
	if ApiSqlListManager.readSqlList2DataFrame()[1]
		Df_JetelinaSqlList = ApiSqlListManager.readSqlList2DataFrame()[2]
		ex = filter(:sql => s -> s == str, Df_JetelinaSqlList)
		if(0<nrow(ex))
			ret = true
		end
	end

	return ret
end
"""
function createApiInsertSentence(key,value)

	create redis set sentence.

# Arguments
- `key::String`: key name
- `value::String`: value data
- return: String: 
"""
function createApiInsertSentence(key, value)
	ret::String = ""
	str =  """set:$key:$value"""
	if(!keyDuplicationCheck(str))
		ret = str
	end

	return ret
end
"""
function createApiSelectSentence(key::String)

	create redis get sentence.

# Arguments
- `key::String`: key name
- return: String
"""
function createApiSelectSentence(key)
	ret::String = ""
	str =  """get:$key"""
	if(!keyDuplicationCheck(str))
		ret = str
	end

	return ret
end
end
