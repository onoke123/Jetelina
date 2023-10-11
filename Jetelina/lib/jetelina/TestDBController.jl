"""
module: TestDBController

Author: Ono keiji
Version: 1.0
Description:
    test db controller for PostgreSQL.
    this module might should be integrated in PgDBController module.:-p

functions
    open_connection()  open connection to the test db.
    close_connection( conn::LibPQ.Connection )  close the test db connection
    doSelect(sql::String,flg::String)  execute ordered sql sentence on test db and acquire its speed.
    measureSqlPerformance()  execute 'select' sql sentence and write the execution speed into a file
"""
module TestDBController

    using CSV, LibPQ, DataFrames, IterTools, Tables
    using JetelinaLog, JetelinaReadConfig
    using JetelinaFiles
    using SQLSentenceManager

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
    function doSelect(sql::String,flg::String)

        execute ordered sql sentence on test db and acquire its speed.

    # Arguments
    - `sql::String`: execute sql sentense
    - return: boolean: false in fale.
    """
    function doSelect(sql)
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
            TestDBController.close_connection(conn)
        end
    end

    """
    function measureSqlPerformance()

        execute 'select' sql sentence and write the execution speed into a file
    """
    function measureSqlPerformance()
        #===
        Df_JetelinaSqlList　に格納されているsqlリストを利用するのがよさそうと思ったが、DF_Jeteli..はGenie空間にあるため、
        web経由でないと利用できない。それだとcronとか別プロセスで利用できないので、JetelinaSqlListを開いて処理することにする。
        ===#
        sqlFile = getFileNameFromConfigPath(JetelinaExperimentSqlList)
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