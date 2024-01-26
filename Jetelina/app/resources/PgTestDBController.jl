"""
module: PgTestDBController

Author: Ono keiji
Version: 1.0
Description:
    test db controller for PostgreSQL.
    this module might should be integrated in PgDBController module.:-p

functions
    open_connection()  open connection to the test db.
    close_connection( conn::LibPQ.Connection )  close the test db connection
    doSelect(sql::String)  execute ordered sql sentence on test db and acquire its speed.
    measureSqlPerformance()  execute 'select' sql sentence and write the execution speed into a file
"""
module PgTestDBController

    using CSV, LibPQ, DataFrames, IterTools, Tables
#    using JetelinaLog, JetelinaReadConfig
#    using JetelinaFiles
#    using PgSQLSentenceManager

    include("JetelinaLog.jl")
    include("JetelinaReadConfig.jl")
    include("JetelinaFiles.jl")
    include("PgSQLSentenceManager.jl")

    export measureSqlPerformance

    """
    function open_connection()

        open connection to the test db.
        connection parameters are set by global variables.

    # Arguments
    - return: LibPQ.Connection object    
    """
    function open_connection()
        conn = LibPQ.Connection("""host = '$JetelinaDBhost' 
            port = '$JetelinaDBport'
            user = '$JetelinaDBuser'
            password = '$JetelinaDBpassword'
            sslmode = '$JetelinaDBsslmode'
            dbname = '$JetelinaTestDBname' """)
    end

    """
    function close_connection( conn::LibPQ.Connection )

        close the test db connection

    # Arguments
    - `conn:LibPQ.Connection`: LibPQ.Connection object
    """
    function close_connection(conn::LibPQ.Connection)
        close(conn)
    end

    """
    function doSelect(sql::String)

        execute ordered sql sentence on test db and acquire its speed.

    # Arguments
    - `sql::String`: execute sql sentense
    - return: boolean: false in fale.
    """
    function doSelect(sql::String)
        conn = open_connection()
        try
                #===
                    Tips:
                        acquire data are 'max','best',"mean'.
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
            # close the connection
            close_connection(conn)
#            PgTestDBController.close_connection(conn)
        end
    end

    """
    function measureSqlPerformance()

        execute 'select' sql sentence and write the execution speed into a file
        Attention: JetelinaExperimentSqlList is created when SQLAnalyzer.main()(indeed createAnalyzedJsonFile()) runs.
                   JetelinaExperimentSqlList does not created if there were not sql.log file and data in it.
                   yes, this measure..() function is called after creating that file in SQLAnalyzer, but for secure. maybe too much.:p

    """
    function measureSqlPerformance()
        #===
            Tips:
                I know it can use Df_JetelinaSqlList here, but wanna leave a evidence what sql are executed.
                That's reason why JetelinaExperimentSqlList file is opend here.
        ===#
        sqlFile = getFileNameFromConfigPath(JetelinaExperimentSqlList)
        if isfile(sqlFile)
            sqlPerformanceFile = getFileNameFromConfigPath(string(JetelinaSqlPerformancefile,".test"))
            open(sqlPerformanceFile, "w") do f
                println(f,string(JetelinaFileColumnApino,',',JetelinaFileColumnMax,',',JetelinaFileColumnMin,',',JetelinaFileColumnMean))
                df = CSV.read( sqlFile, DataFrame )
                for i in 1:size(df,1)
                    if startswith(df.apino[i] ,"js")
                        p = doSelect(df.sql[i])
                        fno::String=df.apino[i]
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

end