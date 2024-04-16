module ChangeParams
    using Jetelina.JFiles, Jetelina.JMessage
    import Jetelina.InitConfigManager.ConfigManager as j_config

    JMessage.showModuleInCompiling(@__MODULE__)

    function update(param::String, var)
        @info "param = var is " param var
        if contains(param,"db type")
            prevparam = j_config.JC["dbtype"] 
            j_config.JC["dbtype"] = var
            _fileupdate(JC["dbtype"],prevparam,var)
        end
    end

    function _fileupdate(param::String, prev,var)
        configfile = JFiles.getFileNameFromConfigPath("JetelinaConfig.cnf")
        configfile_tmp = string(configfile,".1")
        try
            f = open(configfile,"r+")
            tf = open(configfile_tmp,"w")
            l = readlines(f)
            for i ∈ 1:length(l)
                if startswith(l[i],"dbname")
                    @info "find dbname" l[i] prev var
                    p = replace(l[i],prev => var, count=1)
                    @info "later " l[i] p
                else
                    p = l[i]
                end
                #@info i " -> " l[i]
                println(tf,p)
            end

            close(tf)
            close(f)

            mv(configfile_tmp,configfile, force=true)
        catch err
            @error "ChangeParams._fileupdate() error: $err"
        end
    end
end