"""
module: ApiAccessCounter

Author: Ono keiji

Description:
	Counting Api access numbers from sql.log
	
functions
	main() this function set as for kicking createAna..() from outer function.
	collectApiAccessNumbers() 	collect each api(sql) access numbers.
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

	wrap function for executing collectApiAccessNumbers() that is the real analyzing function.
	this function set as for kicking createAna..() from outer function.
"""
function main()
	interval::Integer = parse(Int,j_config.JC["analyze_interval"])
	if isinteger(interval)
		interval = interval*60*60 # transfer hr -> sec
		JLog.writetoLogfile(string("ApiAccessCounter.main() start with : ",j_config.JC["analyze_interval"]," hr interval"))

		task = @async while procflg[]
			collectApiAccessNumbers()
			sleep(interval)
		end
	else
		err = string(JC["analyze_interval"]," is not set in perfect")
		println(err)
		JLog.writetoLogfile("ApiAccessCounter.main() error: $err")
	end
end
"""
function collectApiAccessNumbers()

	collect each api(sql) access numbers.

# Arguments
"""
function collectApiAccessNumbers()
	#===
		Tips:
			read sql.log file
				log/sql.log 
                    ex. 
                        time,apino,exectime,db
                        2024-11-05 10:46:33,js4,0.00123,postgresql
                                   ・
                                   ・
	===#
	sqllogfile = getFileNameFromLogPath(j_config.JC["sqllogfile"])
	if !isfile(sqllogfile)
        procflg[] = false
        errmsg::String = """oh my, there is no log file: $sqllogfile"""
        JLog.writetoLogfile("ApiAccessCounter.collectApiAccessNumbers() error: $errmsg")
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
			start to collect data for creating analyzing files.
			1. api access number
			2. database access number
			3. api execution speed   mean/max/min
	===#
	#===
		Tips:
			get uniqeness 'apino' for '1' & '3'
	===#
	u_api = unique(df[:, :apino])
	part_df = DataFrame(apino = String[], access_numbers = Int[])
	part_df_speed = DataFrame(apino = String[], mean = Float64[], max = Float64[], min = Float64[])

	u_api_size = length(u_api)
	if 0 < u_api_size
		for i ∈ 1:u_api_size
			ac = 0
			# collect access numbers for each unique API. make "access_numbers"
			dd = filter(:apino => x -> x == u_api[i], df)
			ac = nrow(dd)
			speedMax = maximum(dd[:,:exectime])
			speedMin = minimum(dd[:,:exectime])
			speedMean = mean(dd[:,:exectime])
			# move it to here becase it has changed each column name to each sql name.
			push!(part_df, [u_api[i], ac])
			push!(part_df_speed,[u_api[i],speedMean,speedMax,speedMin])
		end

        createAnalyzedJsonFile(part_df, JFiles.getFileNameFromLogPath(j_config.JC["apiaccesscountfile"]),1)
        createAnalyzedJsonFile(part_df_speed, JFiles.getFileNameFromLogPath(j_config.JC["apispeedfile"]),3)
	end
	#===
		Tips:
			get uniqeness 'db' for '2'
	===#
	u_db = unique(df[:, :db])
	part_df = DataFrame(database = String[], access_numbers = Int[])
	u_db_size = length(u_db)
	if 0 < u_db_size
		for i ∈ 1:u_db_size
			ac = 0
			# collect access numbers for each unique API. make "access_numbers"
			dd = filter(:db => x -> x == u_db[i], df)
			ac = nrow(dd)
			# move it to here becase it has changed each column name to each sql name.
			push!(part_df, [u_db[i], ac])
		end

        createAnalyzedJsonFile(part_df, JFiles.getFileNameFromLogPath(j_config.JC["dbaccesscountfile"]),2)
	end
end
"""
function createAnalyzedJsonFile(df::DataFrame)

	create json file for result of sql execution speed analyze data.

# Arguments
- `df::DataFrame`: target dataframe data
- `jsonfile::String`: be operated json file name
- `type::Int`: type of analyzing, 1->api access number, 2->db access number, 3->api speed
"""
function createAnalyzedJsonFile(df::DataFrame, jsonfile::String, type::Int)
	this_df = copy(df)
	date = Dates.today()
	if type == 1
		select!(this_df, :apino, :access_numbers)
	elseif type == 2
		select!(this_df, :database, :access_numbers)
	elseif type == 3
		select!(this_df, :apino, :mean, :max, :min)
	end

	open(jsonfile, "a+") do f
		println(f, JSON.json(Dict("result" => true, "date" => date, "Jetelina" => copy.(eachrow(this_df)))))
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
