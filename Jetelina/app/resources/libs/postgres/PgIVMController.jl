"""
module: PgIVMController

Author: Ono keiji

Description:
	pg_ivm: incrementally maintainable materialized view extension controller for PostgreSQL

functions
    checkIVMExistence() checkin' ivm is availability
"""
module PgIVMController

using Genie, Genie.Renderer, Genie.Renderer.Json
using CSV, LibPQ, DataFrames, IterTools, Tables, Dates
using Jetelina.JFiles, Jetelina.JLog, Jetelina.InitApiSqlListManager.ApiSqlListManager, Jetelina.JMessage, Jetelina.JSession
import Jetelina.InitConfigManager.ConfigManager as j_config

JMessage.showModuleInCompiling(@__MODULE__)

include("PgDBController.jl")

export checkIVMExistence

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
function createIVMtable(apino::String)

    create ivm table from the apino's sql sentence

# Arguments
- `apino::String`: apino in Df_JetelinaSqlList
- return: Boolean: true -> success, false -> couldn't create ivm table 	

"""
function createIVMtable(apino)
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
    
    conn = PgDBController.open_connection()

    try
        LibPQ.execute(conn, executesql)
	catch err
		println(err)
		JLog.writetoLogfile("PgTestDBController.doSelect() with $sql error : $err")
		return false
	finally
		# close the connection
		PgDBController.close_connection(conn)
    end
end
end