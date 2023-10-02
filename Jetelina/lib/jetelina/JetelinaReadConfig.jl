"""
module: JetelinaReadConfig

    read configuration parameters from Jetelina.cnf file
    then set them to global variables
        JetelinaLogfile: log file name
        debugflg: debug mode or not
        JetelinaFileUploadPath: csv file upload path
        JetelinaSQLLogfile: SQL log file name
        JetelinaSQLAnalyzedfile: SQL Analyed json file name
        JetelinaDBhost: DB host name
        JetelinaDBport: DB port number
        JetelinaDBuser: DB access user account
        JetelinaDBpassword: DB access user password
        JetelinaDBsslmode: DB access ssl mode (in PostgreSQL)
        JetelinaDBname: DB database name
        JetelinaTestDBname: DB database for testing by analyzing
    
contain functions
    __init__()
"""

module JetelinaReadConfig

    using JetelinaFiles, JetelinaLog

    export debugflg, JetelinaLogfile, JetelinaDBtype, JetelinaFileUploadPath, JetelinaSQLLogfile, JetelinaDBhost,
        JetelinaDBport, JetelinaDBuser, JetelinaDBpassword, JetelinaDBsslmode, JetelinaDBname, Df_JetelinaTableManager,
        JetelinaSQLAnalyzedfile, JetelinaSQLListfile, JetelinaSqlPerformancefile, JetelinaTableApifile, JetelinaTestDBname,
        JetelinaTestDBDataLimitNumber, JetelinaExperimentSqlList, JetelinaFileColumnApino, JetelinaFileColumnSql,
        JetelinaFileColumnMax, JetelinaFileColumnMin, JetelinaFileColumnMean, JetelinaImprApis

    """
    function __init__()

        auto start this when the server starting.
        this function calls _readConfig function.
    """
    function __init__()
        _readConfig()
    end

    """
    function _readConfig()

        this function is hopefully be private.
        read configuration parameters from JetelinaConfig.cnf file,
        then set them to the global variables.
    """
    function _readConfig()
        configfile = getFileNameFromConfigPath("JetelinaConfig.cnf")

        try
            f = open(configfile, "r")
            l = readlines(f)

            for i = 1:length(l)
                if !startswith(l[i], "#")
                    if startswith(l[i], "logfile")
                        # logfile path attribute
                        global JetelinaLogfile = _getSetting(l[i])
                    elseif startswith(l[i], "debug")
                        # debug configuration true/false
                        global debugflg = parse(Bool, _getSetting(l[i]))
                    elseif startswith(l[i], "fileuploadpath")
                        # CSV file upload path
                        global JetelinaFileUploadPath = _getSetting(l[i])
                    elseif startswith(l[i], "sqllogfile")
                        # SQL log file name
                        global JetelinaSQLLogfile = _getSetting(l[i])
                    elseif startswith(l[i], "sqlanalyzedfile")
                        global JetelinaSQLAnalyzedfile = _getSetting(l[i])
                    elseif startswith(l[i], "sqllistfile")
                        global JetelinaSQLListfile = _getSetting(l[i])
                    elseif startswith(l[i], "sqlperformancefile")
                        global JetelinaSqlPerformancefile = _getSetting(l[i])
                    elseif startswith(l[i], "tableapifile")
                        global JetelinaTableApifile = _getSetting(l[i])
                    elseif startswith(l[i], "experimentsqllistfile")
                        global JetelinaExperimentSqlList = _getSetting(l[i])
                    elseif startswith(l[i], "improvesuggestionfile")
                        global JetelinaImprApis = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_apino")
                        global JetelinaFileColumnApino = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_sql")
                        global JetelinaFileColumnSql = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_max")
                        global JetelinaFileColumnMax = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_min")
                        global JetelinaFileColumnMin = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_mean")
                        global JetelinaFileColumnMean = _getSetting(l[i])
                    elseif startswith(l[i], "dbtype")
                        # DB type
                        global JetelinaDBtype = _getSetting(l[i])
                        if debugflg
                            @info "dbtype:", JetelinaDBtype
                        end

                        if JetelinaDBtype == "postgresql"
                            # for PostgreSQL
                            _setPostgres(l, i + 1)
                        elseif JetelinaDBtype == "mariadb"
                            # for MariaDB
                        elseif JetelinaDBtype == "oracle"
                            # for Oracle
                        end
                    elseif startswith(l[i], "selectlimit")
                        # execution limit number of select sentence in test db
                        global JetelinaTestDBDataLimitNumber = _getSetting(l[i])
                    end
                else
                    # ignore as comment
                end
            end

            close(f)
        catch err
            JetelinaLog.writetoLogfile("Jetelina_readConfig._readConfig() error: $err")
            return false
        end

        return true
    end

    """
    function _getSetting(s::String)

        this function is hopefully be private.
        get value from 's'. 's' is expected 'name=value' style.

    # Arguments
    - `s::String`:  configuration data in 'name=value'. ex. 'debug = true'
    - return: configuration parameter   ex. 'debug = true' parses and gets 'true' 
    """
    function _getSetting(s::String)
        t = split(s, "=")
        tt = strip(t[2])
        return tt
    end

    """
    function _setPostgres(l::String, c::Integer)

        this function is hopefully be private.
        parses and gets then set PostgreSQL connection parameterss to the global variables.

    # Arguments
    - `l::Vector{String}`: configuration file strings
    - `c::Int64`: file line number 
    """
    function _setPostgres(l::Vector{String}, c::Int64)
        for i = c:length(l)
            if !startswith(l[i], "#")
                if startswith(l[i], "host")
                    # DB host
                    global JetelinaDBhost = _getSetting(l[i])
                elseif startswith(l[i], "port")
                    # DB port
                    global JetelinaDBport = parse(Int16, _getSetting(l[i]))
                elseif startswith(l[i], "user")
                    # DB host 
                    global JetelinaDBuser = _getSetting(l[i])
                elseif startswith(l[i], "password")
                    # DB user password
                    global JetelinaDBpassword = _getSetting(l[i])
                elseif startswith(l[i], "sslmode")
                    # DB ssl mode 
                    global JetelinaDBsslmode = _getSetting(l[i])
                elseif startswith(l[i], "dbname")
                    # DB name
                    global JetelinaDBname = _getSetting(l[i])
                elseif startswith(l[i], "testdbname")
                    # analyze test DB name
                    global JetelinaTestDBname = _getSetting(l[i])
                end
            end
        end
    end
end