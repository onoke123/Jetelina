module testparamupdate

    import Jetelina.InitConfigManager.ConfigManager as j_config

    function dbtype()
        @info "dbtype() " j_config.JC["dbtype"] 
    end
end