"""
module: PgIVMController

Author: Ono keiji

Description:
	pg_ivm: incrementally maintainable materialized view extension controller for PostgreSQL

functions
    checkIVMExistence() checkin' ivm is availability
    createIVMtable(conn, apino::String) create ivm table from the apino's sql sentence
    dropIVMtable(conn, ivmapino::String) drop ivm table
    experimentalRun(conn,ivmapino::String) do experimental execution of target ivm api sql sentence
"""
module PgIVMController

using Genie, Genie.Renderer, Genie.Renderer.Json
using CSV, LibPQ, DataFrames, IterTools, Tables, Dates
using Jetelina.JFiles, Jetelina.JLog, Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.JMessage, Jetelina.JSession
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

include("PgDBController.jl")

export checkIVMExistence, createIVMtable, experimentalRun, dropIVMtable

"""
function checkIVMExistence()

    checkin' ivm is availability
	
"""
function checkIVMExistence()
    ret = true # true -> ivm is available false -> not exist

    sql_str = """select * from pg_available_extensions where name ='pg_ivm';"""
    conn = PgDBController.open_connection()
    try
        sql_ret = LibPQ.execute(conn, sql_str)
        retnum = LibPQ.num_affected_rows(sql_ret)
        if retnum == 0
            ret = false
        end
    catch err
        ret = false
        JLog.writetoLogfile("PgIVMController.checkIVMExistence() error: $err")
    finally
        PgDBController.close_connection(conn)
    end

    if ret
        j_config.configParamUpdate(Dict("pg_ivm"=>ret))        
    end

    return ret
end
"""
function createIVMtable(conn, apino::String)

    create ivm table from the apino's sql sentence

# Arguments
- `apino::String`: apino in Df_JetelinaSqlList
- `mode::Bool`: true -> create and keep it  false -> create then drop it
- return: Boolean: true -> success, false -> couldn't create ivm table 	

"""
#function createIVMtable(apino::String, mode::Bool)
function createIVMtable(conn, apino::String)
    target_api = subset(ApiSqlListManager.Df_JetelinaSqlList, :apino => ByRow(==(apino)), skipmissing = true)

    #===
        Tips:
            1. target api name(apino) should be changed to the ivm specail name. eg. js10 -> jv10
            2. escape "'" in the target sql sentence with "''", because "''" is the way of escaping in sql

            then simply kick execute()
    ===#
    ivmapino::String = replace(apino, "js" => "jv")
    sql::String = replace(string(target_api[!,:sql][1], " ", target_api[!,:subquery][1]), "'" => "''")
    executesql::String = """select create_immv('$ivmapino','$sql');"""
    
#    conn = PgDBController.open_connection()

    try
        LibPQ.execute(conn, executesql)
#        if !mode
        return experimentalRun(conn, ivmapino)
#        end
	catch err
		println(err)
		JLog.writetoLogfile("PgIVMController.createIVMtable() with $ivmapino error : $err")
		return false
	finally
		# close the connection
#		PgDBController.close_connection(conn)
    end    
end
"""
function dropIVMtable(conn, ivmapino::String)

    drop ivm table

- `conn::LibPQ.Connection`: postgresql connection 
- `table::String`: apino as ivm
- return:  false -> boolean false 	
"""
function dropIVMtable(conn, ivmapino::String)
    PgDBController.dropTable(["$ivmapino"])
    #===
    sql::String = """drop table $ivmapino;"""

    try
        LibPQ.execute(conn, sql)
	catch err
		println(err)
		JLog.writetoLogfile("PgIVMController.dropIVMtable() with $ivmapino error : $err")
		return false
	finally
    end
    ===#
end
"""
function experimentalRun(conn,ivmapino::String)

    do experimental execution of target ivm api sql sentence
    sql sentence in ivm is definitly simple sql. e.g select * from <ivm table name>

# Arguments
- `conn::LibPQ.Connection`: postgresql connection 
- `ivmapino::String`: apino as ivm
- return:  false -> boolean false true -> tubple(max, min, mean) 	
"""
function experimentalRun(conn, ivmapino::String)
    sql::String = """select * from $ivmapino"""

    return PgDBController.doSelect(sql, "measure")
    #===
    try
		#===
			Tips:
				acquire data are 'max','best',"mean'.
		===#
		exetime = []
		looptime = 10
		for loop in 1:looptime
			stats = @timed z = LibPQ.execute(conn, sql)
			push!(exetime, stats.time)
		end

        return findmax(exetime), findmin(exetime), sum(exetime) / looptime
	catch err
		println(err)
		JLog.writetoLogfile("PgIVMController.experimentalRun() with $ivmapino error : $err")
		return false
	finally
#        dropIVMtable(conn, ivmapino)
	end
    ===#
end
"""
function executeJSApi(conn, apino::String)

	execute ordered sql(js*) sentence to compare with jv* execution speed

# Arguments
- `apino::String`: execute target api number e.g js10
- return: ((max speed, sample number),(minimum speed, sample number), mean ), fale -> boolean: false. 
"""
function executeJSApi(conn, apino::String)
    target_api = subset(ApiSqlListManager.Df_JetelinaSqlList, :apino => ByRow(==(apino)), skipmissing = true)
    sql::String = string(target_api[!,:sql][1], " ", target_api[!,:subquery][1])

    return PgDBController.doSelect(sql,"measure")
#===
    try
		#===
			Tips:
				acquire data are 'max','best',"mean'.
		===#
		exetime = []
		looptime = 10
		for loop in 1:looptime
			stats = @timed z = LibPQ.execute(conn, sql)
			push!(exetime, stats.time)
		end

		return findmax(exetime), findmin(exetime), sum(exetime) / looptime
	catch err
		println(err)
		JLog.writetoLogfile("PgTestDBController.executeJSApi() with $sql error : $err")
		return false
	finally
		# close the connection
#		PgDBController.close_connection(conn)
	end
    ===#
end

"""
function compareJsAndJv()

    compare max/min/mean execution speed between js* and jv*.

"""
function compareJsAndJv()
    conn = PgDBController.open_connection()
	apis::Array = collectIvmCandidateApis()

    try
        for apino in apis
            jsspeed = executeJSApi(conn, string(apino))
            jvspeed = executeIVMtest(conn, string(apino))

            if j_config.JC["debug"]
                @info "jsspeed: " jsspeed
                @info "jvspeed: " jvspeed
                @info "speed compare: jv_mean - js_mean " (jvspeed[3] - jsspeed[3])
            end

            if jsspeed[3] < jvspeed[3]
                ivmapino::String = replace(apino, "js" => "jv")
                @info "dropped " ivmapino
                dropIVMtable(conn, ivmapino)
            else
                @info "write to the file " apino
                ApiSqlListManager.writeToMatchinglist(string(apino))
            end
        end
    catch err
        println(err)
		JLog.writetoLogfile("PgIVMController.compareJsAndJv() error : $err")
    finally
		# close the connection
		PgDBController.close_connection(conn)
    end
end
end