"""
module: JetelinaReadConfig

    read configuration parameters from Jetelina.cnf file
    then set them to global variables

    contain functions
        __init__()
"""

module JetelinaReadConfig

    using JetelinaFiles, JetelinaLog

    export  JetelinaLogfile,# log file name
        debugflg,# debug configuration true/false
        JetelinaFileUploadPath,# csv file upload path
        JetelinaSQLLogfile,# SQL log file name
        JetelinaSQLAnalyzedfile,# real sql execution test data in json form
        JetelinaSQLListfile,# real sql list file name
        JetelinaSqlPerformancefile,# original text file of 'sqlanalyzedfile'
        JetelinaTableApifile,# file name for relation between talbe name and api no
        JetelinaExperimentSqlList,# sql list file for execution in test db
        JetelinaImprApis,# suggestion file name due to execute test db
        JetelinaFileColumnApino,# column title of sqllogfile/sqllistfile/experimentalsqllistfile
        JetelinaFileColumnSql,# column title of sqllogfile/sqllistfile/experimentalsqllistfile
        JetelinaFileColumnMax,# column title of sqllogfile/sqllistfile/experimentalsqllistfile
        JetelinaFileColumnMin,# column title of sqllogfile/sqllistfile/experimentalsqllistfile
        JetelinaFileColumnMean,# column title of sqllogfile/sqllistfile/experimentalsqllistfile
        JetelinaDBtype,# type of database
        JetelinaDBhost,# DB host name
        JetelinaDBport,# DB port number
        JetelinaDBuser,# DB access user account
        JetelinaDBpassword,# DB access user password
        JetelinaDBsslmode,# DB access ssl mode (in PostgreSQL)
        JetelinaDBname,# DB database name
        JetelinaTestDBname,# DB database for testing by analyzing
        JetelinaTestDBDataLimitNumber,# execution limit number of select sentence in test db
        JetelinaReadingLogMaxLine # maxmum lines to read 'sqllogfile'

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
                        # log file name
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
                        # real sql execution test data file name in json form
                        global JetelinaSQLAnalyzedfile = _getSetting(l[i])
                    elseif startswith(l[i], "sqllistfile")
                        # real sql list file name
                        global JetelinaSQLListfile = _getSetting(l[i])
                    elseif startswith(l[i], "sqlperformancefile")
                        # original text file of 'sqlanalyzedfile'
                        global JetelinaSqlPerformancefile = _getSetting(l[i])
                    elseif startswith(l[i], "tableapifile")
                        # file name for relation between talbe name and api no
                        global JetelinaTableApifile = _getSetting(l[i])
                    elseif startswith(l[i], "experimentsqllistfile")
                        # sql list file for execution in test db
                        global JetelinaExperimentSqlList = _getSetting(l[i])
                    elseif startswith(l[i], "improvesuggestionfile")
                        # suggestion file name due to execute test db
                        global JetelinaImprApis = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_apino")
                        # column title of sqllogfile/sqllistfile/experimentalsqllistfile
                        global JetelinaFileColumnApino = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_sql")
                        # column title of sqllogfile/sqllistfile/experimentalsqllistfile
                        global JetelinaFileColumnSql = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_max")
                        # column title of sqllogfile/sqllistfile/experimentalsqllistfile
                        global JetelinaFileColumnMax = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_min")
                        # column title of sqllogfile/sqllistfile/experimentalsqllistfile
                        global JetelinaFileColumnMin = _getSetting(l[i])
                    elseif startswith(l[i], "file_column_mean")
                        # column title of sqllogfile/sqllistfile/experimentalsqllistfile
                        global JetelinaFileColumnMean = _getSetting(l[i])
                    elseif startswith(l[i], "dbtype")
                        # type of database
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
                    elseif startswith(l[i], "reading_max_lines")
                        # maxmum lines to read 'sqllogfile'
                        global JetelinaReadingLogMaxLine = _getSetting(l[i])
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