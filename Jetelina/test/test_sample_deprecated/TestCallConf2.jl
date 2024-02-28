module TestCallConf2
    import Jetelina.InitConfigManager.ConfigManager as p

    const j_con = p

    function main()
        @info "conf is " p.JC["pg_port"]
    end
end