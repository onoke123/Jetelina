"""
    module: PgTestDBController

DB controller for testdb in PostgreSQL

contain functions
    open_connection()
    close_connection( conn )
    doSelect()

    measureSqlPerformance()
"""
module TestDBController

#using Genie, Genie.Renderer, Genie.Renderer.Json
using CSV, LibPQ, DataFrames, IterTools, Tables
using JetelinaLog, JetelinaReadConfig
#using PgDataTypeList
using JetelinaFiles
using SQLSentenceManager


"""
    function open_connection()

open connection to the DB.
connection parameters are set by global variables.
"""
function open_connection()
    #===
    @info "host = '$JetelinaDBhost' 
    port = '$JetelinaDBport'
    user = '$JetelinaDBuser'
    password = '$JetelinaDBpassword'
    sslmode = '$JetelinaDBsslmode'
    dbname = '$JetelinaTestDBname' "
    ===#
    conn = LibPQ.Connection("""host = '$JetelinaDBhost' 
        port = '$JetelinaDBport'
        user = '$JetelinaDBuser'
        password = '$JetelinaDBpassword'
        sslmode = '$JetelinaDBsslmode'
        dbname = '$JetelinaTestDBname' """)
end

"""
    function close_connection( conn )

# Arguments
- `conn: Object`: connection object

close the DB connection
"""
function close_connection(conn)
    close(conn)
end


"""
    function doSelect( sql,flg )

# Arguments
- `sql: String`: execute sql sentense
#- `mode: String`: "run"->running mode  "measure"->measure speed. only called by measureSqlPerformance()
"""
function doSelect(sql)
    conn = open_connection()
    try
            #===
                取得するデータは、max,best,meanの三種類とする。
            ===#
            exetime = []
            looptime = 10
            for loop in 1:looptime
                stats = @timed z = LibPQ.execute(conn, sql)
                push!(exetime,stats.time)
            end

            return findmax(exetime), findmin(exetime), sum(exetime)/looptime
    catch err
        println(err)
        JetelinaLog.writetoLogfile("PgTestDBController.doSelect() with $mode $sql error : $err")
        return false
    finally
        #ここまで来たらconnを閉じる
        close_connection(conn)
    end
end

"""
    function measureSqlPerformance()

# Arguments。
    measure sql exectution time
"""
function measureSqlPerformance()
    #===
     Df_JetelinaSqlList　に格納されているsqlリストを利用するのがよさそうと思ったが、DF_Jeteli..はGenie空間にあるため、
     web経由でないと利用できない。それだとcronとか別プロセスで利用できないので、JetelinaSqlListを開いて処理することにする。
    ===#
    sqlFile = getFileNameFromConfigPath(JetelinaSQLListfile)
    sqlPerformanceFile = getFileNameFromConfigPath(JetelinaSqlPerformancefile)

    open(sqlPerformanceFile, "w") do f
        println(f,"no,max,min,mean")
        df = CSV.read( sqlFile, DataFrame )
        for i in 1:length(df)
            if startswith(df.no[i] ,"js")
                p = doSelect(df.sql[i],"measure")
                fno::String=df.no[i]
                fmax::Float64=p[1][1]
                fmin::Float64=p[2][1]
                fmean::Float64=p[3]
                s = """$fno,$fmax,$fmin,$fmean"""
                println(f,s)
            end
        end
    end
end

end