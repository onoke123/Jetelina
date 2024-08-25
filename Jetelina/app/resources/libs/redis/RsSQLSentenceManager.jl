"""
module: RsSQLSentenceManager

Author: Ono keiji

Description:
	DB controller for Redis

functions
	keyDuplicationCheck(nsql::String, subq::String)  confirm duplication, if 'nsql' exists in JC["sqllistfile"].but checking is in Df_JetelinaSqlList, not the real file, because of execution speed. 
	createApiInsertSentence(key::String,value::String)	create redis set sentence.
	createApiSelectSentence(key::String) create redis get sentence.
	createExecutionSqlSentence(json_dict::Dict, df::DataFrame) create real execution SQL sentence.
"""
module RsSQLSentenceManager

using DataFrames, StatsBase
using Genie, Genie.Requests, Genie.Renderer.Json
using Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.JMessage

JMessage.showModuleInCompiling(@__MODULE__)

export keyDuplicationCheck, createApiInsertSentence, createApiSelectSentence, createExecutionSqlSentence

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
function createApiInsertSentence(key::String,value::String)

	create redis set sentence.

# Arguments
- `key::String`: key name
- `value::String`: value data
- return: String: 
"""
function createApiInsertSentence(key::String, value::String)
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
function createApiSelectSentence(key::String)
	ret::String = ""
	str =  """get:$key"""
	if(!keyDuplicationCheck(str))
		ret = str
	end

	return ret
end
"""
function createExecutionSqlSentence(json_dict::Dict, df::DataFrame)

	create real execution SQL sentence.
	using 'ignore' and 'subquery' as keywords to create SQL sentence. 
	These are the 'PROTOCOL' in using DataFrame of SQL list and posting data I/F.
	
	Attention: this select sentence searchs only 'jetelina_delete_flg=0" data.

# Arguments
- `json_dict::Dict`:  json raw data, uncertain data type        
- `df::DataFrame`: dataframe of target api data. a part of Df_JetelinaSqlList 
- return::String SQL sentence
"""
function createExecutionSqlSentence(json_dict::Dict, df::DataFrame)
	keyword1::String = "ignore" # protocol
	keyword2::String = "subquery" # protocol
	j_del_flg::String = "jetelina_delete_flg=0" # absolute select condition
	subquery_str::String = "" # contain df.subquery[1]. see Tips
	ret::String = "" # return sql sentence
	json_subquery_dict = Dict()
	execution_sql::String = ""

	#===
		Tips:
			this is a private function.
			this function manages building 'jetelina_delete_flg' subquery.
			in order to handle multi table, this 'jetelina_delete_flg' is also set as multi.
			i mean
				table1.jetelina_delete_flg=0 and table2.jetelina_delete_flg=0 and....

			Caution: any local variables are not be duplicated with global ones. 
	===#
	function __create_j_del_flg(sql::String)
		del_flg::String = "jetelina_delete_flg=0" # absolute select condition

		div_sql = split(sql, "from")
		if !isnothing(div_sql)
			if contains(div_sql[2], ',')
				tables = split(div_sql[2], ',')
				if !isnothing(tables)
					multi_del_flg::String = ""
					for i in eachindex(tables)
						table = split(tables[i], "as")
						if !isnothing(table)
							if length(multi_del_flg) == 0
								multi_del_flg = string(strip(table[1]), ".jetelina_delete_flg=0")
							else
								multi_del_flg = string(multi_del_flg, " and ", strip(table[1]), ".jetelina_delete_flg=0")
							end
						end
					end

					del_flg = multi_del_flg
				end
			end
		end

		return del_flg
	end

	#===
		Tips:
			this is a private function.
			this function manages building subquery string.
			because of 'limit' or something like this additions, 'jetelina_delete_flg' position has to be arranged.
			i think it is good as setting it at the head, like
				select .... where jetelina_delete_flg=0 and table1.something='aaa' limit 10 

			Caution: any local variables are not be duplicated with global ones. 
	===#
	function __create_subquery_str(sub_str::String, del_str::String)
		sub_ret::String = sub_str

		if contains(sub_str, "where")
			ss = split(sub_str, "where")
			if !isnothing(ss)
				sub_ret = string("where ", del_str, " and ", strip(ss[2]))
			end
		end

		return sub_ret
	end

	if 0 < length(json_dict)
		#===
			Tips:
				case in 'insert' has a chance of 'missing' in df.subquery[1].

				Attention: 
					using 'subquery_str' String type has a benefit rather than using df.subquery[1],
					because df fields length are fixed as DataFrame when it was created.
					I mean using straight as df.* may happen over flow in the case of concate strings.
						ex. df.subquery[1] -> fixed String(10) in DataFrame
								 df.subquery[1] = string(df.subquery[1], "AAAAAAAA") -> maybe get over flow 
		===#
		if !ismissing(df.subquery[1])
			subquery_str = df.subquery[1]
		end

		if contains(json_dict["apino"], "js")
			# select
			if !isnothing(subquery_str) && !contains(subquery_str, keyword1) && !ismissing(subquery_str)
				#===
					Tips:
						set subquery data in json to df.subquery.
						because it combines later with df.sql.
						managing df.subquery is very advantageous process at here.
				===#
				if haskey(json_dict, keyword2)
					sp = split(json_dict[keyword2], ",")
					if !isnothing(sp)
						for ii in eachindex(sp)
							if ii == 1 || ii == length(sp)
								sp[ii] = replace.(sp[ii], "[" => "", "]" => "", "\"" => "", "'" => "")
							end

							ssp = split(sp[ii], ":")
							if !isnothing(ssp) && 1<length(ssp)
								json_subquery_dict[ssp[1]] = ssp[2]
							end
						end
					end

					for (k, v) in json_subquery_dict
						kk = string("{", k, "}")
						subquery_str = replace.(subquery_str, kk => v)
					end

					# this private function __create_j_del_flg() is defined above.
					j_del_flg = __create_j_del_flg(df.sql[1])
					# this private function __create_subquery_str is defined above as well.
					subquery_str = __create_subquery_str(subquery_str, j_del_flg)
				end
			else
				subquery_str = string("where ", j_del_flg)
			end
		elseif contains(json_dict["apino"], "ju") || contains(json_dict["apino"], "jd")
			# update/delete
			#   json_dict["subquery"] is always point to {jt_id}
			json_dict["jt_id"] = json_dict["subquery"]
		else
			# insert/update
			#   insert always needs to add 'jetelina_delete_flg' as 0.
			json_dict["jetelina_delete_flg"] = 0
		end

		execution_sql = string(df.sql[1], " ", subquery_str)

		#==
			Tips:
				json data bind to the sql sentence.
				Dict() is used alike associative array.
		===#
		for (k, v) in json_dict
			kk = string("{", k, "}")
			execution_sql = replace.(execution_sql, kk => v)
		end

		ret = execution_sql
	end

	return ret
end
end
