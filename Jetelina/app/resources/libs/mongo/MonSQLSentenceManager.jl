"""
module: MonSQLSentenceManager

Author: Ono keiji

Description:
	DB controller for Redis

functions
	keyDuplicationCheck(nsql::String, subq::String)  confirm duplication, if 'nsql' exists in JC["sqllistfile"].but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 
	createApiInsertSentence() create redis general set sentence.
	createApiUpdateSentence(key) create redis set sentence.this sentence is for updating an existence data.
	createApiSelectSentence(key) create redis get sentence.
"""
module MonSQLSentenceManager

using DataFrames, StatsBase
using Genie, Genie.Requests, Genie.Renderer.Json
using Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.JMessage

JMessage.showModuleInCompiling(@__MODULE__)

export keyDuplicationCheck, createApiInsertSentence, createApiSelectSentence

"""
function keyDuplicationCheck(str::String)

	confirm duplication, if 'str' exists in JC["sqllistfile"].
	but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 

# Arguments
- `str::String`: something json key data
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
	if 0 < nrow(ApiSqlListManager.Df_JetelinaSqlList)
		df = ApiSqlListManager.Df_JetelinaSqlList
		ex = filter(:sql => s -> s == str, df)
		if(0<nrow(ex))
			ret = true
		end
	end

	return ret
end
"""
function createApiInsertSentence()

	create MongoDb general insert sentence.
	this function always inserts a new collection, therefore no need to check for duplication in the sql list, maybe.

# Arguments
- return: String: 
"""
function createApiInsertSentence()
#	ret::String = ""

	ret::String =  """<set your json with an unique 'j_table'>"""

#	if(!keyDuplicationCheck(str))
#		ret = str
#	end

	return ret
end
"""
function createApiUpdateSentence(str::String)

	create mongodb update sentence.
	this function always works for an unique collection, therefore no need to check for duplication in the sql list, maybe.

# Arguments
- `str::String`: json string
- return: String: 
"""
function createApiUpdateSentence(str::String)
#	ret::String = ""
	ret::String =  """{\$set:$str}"""

#	if(!keyDuplicationCheck(str))
#		ret = str
#	end

	return ret
end
"""
function createApiSelectSentence(key)

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
