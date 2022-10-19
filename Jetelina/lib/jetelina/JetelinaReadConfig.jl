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
    export  JetelinaLogfile, debugflg, JetelinaFileUploadPath, JetelinaDBPath,JetelinaDBhost,JetelinaDBport,JetelinaDBuser,JetelinaDBpassword,JetelinaDBsslmode,JetelinaDBname

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
        #println( "JetelinaReadCOnfig.jl config file is: ", configfile )

        f = open( configfile, "r" )
        l = readlines( f )

        for i = 1:size(l)[1]
            if !startswith( l[i],"#" )
                if startswith( l[i],"logfile" )
                    #===
                       logfile path attribute
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    
                    #println( "JetelinaReadCOnfig.jl logfile: ", tt )
                
                    global JetelinaLogfile = tt

                elseif startswith( l[i], "debug" )
                    #===
                        debug configuration true/false
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    if tt == "true"
                        global debugflg = true
                    else
                        global debugflg = false
                    end

                elseif startswith( l[i], "fileuploadpath" )
                    #===
                        CSV file upload path
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    global JetelinaFileUploadPath = tt
                elseif startswith( l[i], "host")
                    #===
                        DB host 
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    global JetelinaDBhost = tt
                elseif startswith( l[i], "port")
                    #===
                        DB port
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    global JetelinaDBport = tt
                elseif startswith( l[i], "user")
                    #===
                        DB host 
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    global JetelinaDBuser = tt
                elseif startswith( l[i], "password")
                    #===
                        DB user password
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    global JetelinaDBpassword = tt
                elseif startswith( l[i], "sslmode")
                    #===
                        DB ssl mode 
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    global JetelinaDBsslmode = tt
                elseif startswith( l[i], "dbname")
                    #===
                        DB name
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    global JetelinaDBname = tt
                elseif startswith( l[i], "dbpath" )
                    #===
                        database path
                    ===#
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    global JetelinaDBPath = tt
                end
            else
                # ignore as comment
            end

        end
    end

end