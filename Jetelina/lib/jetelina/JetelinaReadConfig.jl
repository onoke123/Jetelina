"""
    module: JetelinaReadConfig

read configuration parameters from Jetelina.cnf file
then set them to global variables
    JetelinaLogfile: log file name
    debugflg: debug mode or not
    JetelinaFileUploadPath: csv file upload path
    JetelinaDBhost: DB host name
    JetelinaDBport: DB port number
    JetelinaDBuser: DB access user account
    JetelinaDBpassword: DB access user password
    JetelinaDBsslmode: DB access ssl mode (in PostgreSQL)
    JetelinaDBname: DB database name

contain functions
    __init__()
    readConfig()
    getSetting(s)
    setPostgres(l,c)
"""

module JetelinaReadConfig
    using DBDataController

    export  debugflg,JetelinaLogfile,JetelinaDBtype,JetelinaFileUploadPath,JetelinaDBhost,
    JetelinaDBport,JetelinaDBuser,JetelinaDBpassword,JetelinaDBsslmode,JetelinaDBname,Df_JetelinaTableManager

    """
        function __init__()

    auto start this when the server starting.
    this function calls readConfig function.
    """
    function __init__()
        readConfig()
        DBDataController.init_Jetelina_table()
    end

    """
        function readConfig()

    read configuration parameters from JetelinaConfig.cnf file,
    then set them to the global variables.
    """
    function readConfig()
        configfile = string( joinpath( @__DIR__, "config", "JetelinaConfig.cnf" ))

        f = open( configfile, "r" )
        l = readlines( f )

        debf::Bool = false
        for i = 1:size(l)[1]
            if !startswith( l[i],"#" )
                if startswith( l[i],"logfile" )
                    # logfile path attribute
                    global JetelinaLogfile = getSetting(l[i])
                elseif startswith( l[i], "debug" )
                    # debug configuration true/false
                    global debugflg = parse( Bool, getSetting(l[i]) )
                elseif startswith( l[i], "fileuploadpath" )
                    # CSV file upload path
                    global JetelinaFileUploadPath = getSetting(l[i])
                elseif startswith( l[i], "dbtype")
                    # DB type
                    global JetelinaDBtype = getSetting(l[i])
                    @info "dbtype:", JetelinaDBtype
                    if JetelinaDBtype == "postgresql"
                        # for PostgreSQL
                        setPostgres(l,i+1)
                    elseif JetelinaDBtype == "mariadb"
                        # for MariaDB
                    elseif JetelinaDBtype == "oracle"
                        # for Oracle
                    end
                end
            else
                # ignore as comment
            end
        end
    end

    """
        function getSetting(s)
    
    # Arguments
    - `s: String`:  ex. 'debug = true'
    return: configuration parameter   ex. 'debug = true' parses and gets 'true' 
    
    parses s with '=' then gets and returns the paramter.
    """
    function getSetting(s)
        t = split( s, "=" )
        tt = strip( t[2] )
        return tt
    end

    """
        function setPostgres(l,c)
    
    # Arguments
    - `l: String`: configuration file strings
    - `c: Integer`: file line number 

            parses and gets then set PostgreSQL connection parameterss to the global variables
    """
    function setPostgres(l,c)
        for i = c:size(l)[1]
            if !startswith( l[i],"#" )
                if startswith( l[i],"host" )
                    # DB host
                    global JetelinaDBhost = getSetting(l[i])
                elseif startswith( l[i], "port")
                    # DB port
                    global JetelinaDBport = parse( Int16, getSetting(l[i]) )
                elseif startswith( l[i], "user")
                    # DB host 
                    global JetelinaDBuser = getSetting(l[i])
                elseif startswith( l[i], "password")
                    # DB user password
                    global JetelinaDBpassword = getSetting(l[i])
                elseif startswith( l[i], "sslmode")
                    # DB ssl mode 
                    global JetelinaDBsslmode = getSetting(l[i])
                elseif startswith( l[i], "dbname")
                    # DB name
                    global JetelinaDBname = getSetting(l[i])
                end
            end
        end
    end
end