module TestCallConf2
    import Jetelina.CallReadConfig.ReadConfig as p

    const j_con = p

    function main()
        @info "conf is " p.JetelinaDBport
    end
end