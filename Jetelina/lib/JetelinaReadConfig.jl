#===
   Jetelina read configuration file, then set them to Glogal variables
===#

module JetelinaReadconfig

    global JetelinaLogfile
    
    function ini()
        configfile = string( joinpath( "config", "JetelinaConfig.cnf" ))
        f = open( configfile, "r" )
        l = readlines( f )

        for i = 1:size(l)[1]
            println( l[i] )

            if !startswith( l[i],"*" )
                if startswith( l[i],"logfile")
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    println( "logfile: ", tt )
                    JetelinaLogfile = tt
                end
            else
                # ignore as comment
            end
        end
    end

    function getLogfile()
        return JetelinaLogfile
    end
end