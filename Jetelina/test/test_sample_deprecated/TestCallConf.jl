module TestCallConf
    import Jetelina.CallReadConfig.ReadConfig as p

    const j_con = p

    function main()
        @info "conf is " p.JetelinaDBport
    end

    function cg(s)
        p.JetelinaDBport = s
    end
end