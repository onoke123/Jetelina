#===
    @m: JetelinaReadConfig
    @v: 0.1
    @q: non
    @r: global variables: JetelinaLogfile(log file path&name), debugflg(true/false)
    @d: Jetelina read configuration file, then set them to Glogal variables
    @e:
    @s:
===#

module JetelinaReadConfig
    export  JetelinaLogfile, debugflg, JetelinaFileUploadPath,
     JetelinaDBPath,JetelinaDBhost,JetelinaDBport,JetelinaDBuser,JetelinaDBpassword,JetelinaDBsslmode,JetelinaDBname

    #===
        @m: JetelinaReadConfig
        @f: __init__()
        @v: 0.1
        @q: non
        @r: non
        @d: Jetelina read configuration file, then set them to Glogal variables
        @e:
        @s:
    ===#
    function __init__()
        readConfig()
    end

    #===
        Configファイル読み込みの実体
        JetelinaConfig.cnfが変更されたらこの関数を実行して設定値を有効にする
        __init__()と分けることでGenie再起動が不要になる
    ===#
    function readConfig()
        configfile = string( joinpath( @__DIR__, "config", "JetelinaConfig.cnf" ))

        f = open( configfile, "r" )
        l = readlines( f )

        for i = 1:size(l)[1]
            if !startswith( l[i],"#" )
                if startswith( l[i],"logfile" )
                    # logfile path attribute
                    global JetelinaLogfile = getSetting(l[i])
                elseif startswith( l[i], "debug" )
                    # debug configuration true/false
                    global debugflg = getSetting(l[i])
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

    #===
        get the parameter from the string
    ===#
    function getSetting(s)
        t = split( s, "=" )
        tt = strip( t[2] )
        return tt
    end

    #===
        PostgreSQL
    ===#
    function setPostgres(l,c)
        for i = c:size(l)[1]
            if !startswith( l[i],"#" )
                if startswith( l[i],"host" )
                    # DB host
                    global JetelinaDBhost = getSetting(l[i])
                elseif startswith( l[i], "port")
                    # DB port
                    global JetelinaDBport = getSetting(l[i])
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