#===
   Jetelina read configuration file, then set them to Glogal variables
===#

module JetelinaReadconfig
    export  JetelinaLogfile, getLogfile

    function __init__()
        configfile = string( joinpath( "config", "JetelinaConfig.cnf" ))
        f = open( configfile, "r" )
        l = readlines( f )

        for i = 1:size(l)[1]
            if !startswith( l[i],"*" )
                if startswith( l[i],"logfile")
                    t = split( l[i], "=" )
                    tt = strip( t[2] )
                    
                    #println( "JetelinaReadCOnfig.jl logfile: ", tt )
                    
                    global JetelinaLogfile = tt
                end
            else
                # ignore as comment
            end

        end
    end

end