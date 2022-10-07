#==
    csv file upload controller
==#
module FileUploadController

    using Genie, Genie.Requests
    using JetelinaReadConfig, JetelinaLog
    using CSVFileController

    function fup()
        #==
            caution: :upfile is depend on fileupload.html
        ==#
        if infilespayload(:upfile)
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

            #===
             only the first row is read and responsed to
             change this number if you wanna read multi rows
                ex. r = 2   read 2rows from the first

             why uses 'local', beacause of making clear it as local variable
            ===#
            local r = 1
            CSVFileController.read( csvfilename, r )
        else
            "No file uploaded"
        end
    end
end