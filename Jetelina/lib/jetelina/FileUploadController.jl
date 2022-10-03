module FileUploadController

    using Genie, Genie.Requests
    using JetelinaReadConfig, JetelinaLog
    using CSVFileController

    function fup()
        if infilespayload(:yourfile)
            csvfilename = ""
            files = Genie.Requests.filespayload()
            for f in files
                csvfilename = joinpath( JetelinaFileUploadPath, f[2].name )
                @info "csvfilename:" * csvfilename
                write( csvfilename, f[2].data)
                #@info "Uploading: " * f[2].name
            end
            if length(files) == 0
                @info "No file uploaded"
            end
        
            #stat(filename(filespayload(:yourfile)))
            CSVFileController.read( csvfilename )
        else
            "No file uploaded"
        end
    end
end