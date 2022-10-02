module FileUploadController

    using Genie, Genie.Requests
    using JetelinaReadConfig, JetelinaLog

    function fup()
        if infilespayload(:yourfile)
            files = Genie.Requests.filespayload()
            for f in files
                write(joinpath( JetelinaFileUploadPath, f[2].name), f[2].data)
                @info "Uploading: " * f[2].name
            end
            if length(files) == 0
                @info "No file uploaded"
            end
        
            stat(filename(filespayload(:yourfile)))
          else
            "No file uploaded"
          end
    end
end