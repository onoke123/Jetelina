module testparamupdate

    import Jetelina.CallReadConfig.ReadConfig as j_config

    function dbtype()
        @info "dbtype() " j_config.JetelinaDBtype 
    end
end