"""
module: FileUploadController

Author: Ono keiji
Version: 1.0
Description:
    csv file upload controller

functions
    fup() upload the csv file from fileuplaod.html.
"""
module FileUploadController

    using Genie, Genie.Requests

    include("CSVFileController.jl")    

    export fup
    
    """
    function fup()

        upload the csv file from fileuplaod.html.
        caution: ':upfile'(html tag id) is depend on fileupload.html
    """
    function fup()
        if infilespayload(:upfile)
            csvfilename = ""
            files = Genie.Requests.filespayload()
            for f in files
                csvfilename = joinpath( JetelinaFileUploadPath, f[2].name )    
                write( csvfilename, f[2].data)
            end
    
            if length(files) == 0
                @info "FileUploadController.fup() No file uploaded"
            end
        
            CSVFileController.read( csvfilename )
        else
            "No file uploaded"
        end
    end
end