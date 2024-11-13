"""
module: ApiAccessCounter

Author: Ono keiji

Description:
	Counting Api access numbers from sql.log
	
functions
	main() this function set as for kicking createAna..() from outer function.
	collectSqlAccessNumbers() 	collect each api(sql) access numbers.
	createAnalyzedJsonFile(df::DataFrame)  create json file for result of sql execution speed analyze data.
	stopanalyzer() manual stopper for repeating analyzring
"""
module ApiAccessCounter

using JSON, LibPQ, Tables, CSV, DataFrames, StatsBase, DelimitedFiles, Dates
using Genie, Genie.Renderer, Genie.Renderer.Json
using Jetelina.JLog, Jetelina.JFiles, Jetelina.JMessage
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

procflg = Ref(true) # analyze process progressable -> true, stop/error -> false

"""
function main()

	wrap function for executing collectSqlAccessNumbers() that is the real analyzing function.
	this function set as for kicking createAna..() from outer function.
"""
function main()
	interval::Integer = parse(Int,j_config.JC["analyze_interval"])
	if isinteger(interval)
		interval = interval*60*60 # transfer hr -> sec
		JLog.writetoLogfile(string("ApiAccessCounter.main() start with : ",j_config.JC["analyze_interval"]," hr interval"))

		task = @async while procflg[]
			collectSqlAccessNumbers()
			sleep(interval)
		end
	else
		err = string(JC["analyze_interval"]," is not set in perfect")
		println(err)
		JLog.writetoLogfile("ApiAccessCounter.main() error: $err")
	end
end
"""
function collectSqlAccessNumbers()

	collect each api(sql) access numbers.

# Arguments
"""
function collectSqlAccessNumbers()
	#===
		Tips:
			read sql.log file
				log/sql.log 
                    ex. 
                        time,apino,exectime,db
                        2024-11-05 10:46:33,js4,postgresql
                                   ・
                                   ・
	===#
	sqllogfile = getFileNameFromLogPath(j_config.JC["sqllogfile"])
	if !isfile(sqllogfile)
        procflg[] = false
        errmsg::String = """oh my, there is no log file: $sqllogfile"""
        JLog.writetoLogfile("ApiAccessCounter.collectSqlAccessNumbers() error: $errmsg")
        return
	end

    #===
        Tips:
            this 'reading_max_lines' is for secure.
            because who knows how much big the file is.
    ===#
	maxrow::Int = j_config.JC["reading_max_lines"]
	df = CSV.read(sqllogfile, DataFrame, limit = maxrow)
	#===
		Tips:
			get uniqeness 'apino'
	===#
	u = unique(df[:, :apino])
#	sql_df = DataFrame(apino = String[], sql = String[], combination = Vector{String}[], access_numbers = Float64[])
	sql_df = DataFrame(apino = String[], access_numbers = Float64[])

	u_size = length(u)
	if 0 < u_size
		for i ∈ 1:u_size
			ac = 0
			# collect access numbers for each unique SQL. make "access_numbers"
			dd = filter(:apino => x -> x == u[i], df)
			ac = nrow(dd)
			# move it to here becase it has changed each column name to each sql name.
#			push!(sql_df, [u[i], df[:, :sql][i], table_arr, ac])
			push!(sql_df, [u[i], ac])
		end

        createAnalyzedJsonFile(sql_df)
	end
end
"""
function createAnalyzedJsonFile(df::DataFrame)

	create json file for result of sql execution speed analyze data.

# Arguments
- `df::DataFrame`: target dataframe data
"""
function createAnalyzedJsonFile(df::DataFrame)
	this_df = copy(df)
	sqlaccessnumberfile = JFiles.getFileNameFromLogPath(j_config.JC["sqlaccesscountfile"])
	# delete this file if it exists, because this file is always fresh.
	rm(sqlaccessnumberfile, force = true)

	select!(this_df, :apino, :access_numbers)
	open(sqlaccessnumberfile, "w") do f
		println(f, JSON.json(Dict("result" => true, "Jetelina" => copy.(eachrow(this_df)))))
	end
end
"""
function stopanalyzer()

	manual stopper for analyzring repeat
"""
function stopanalyzer()
	procflg[] = false
end

end
