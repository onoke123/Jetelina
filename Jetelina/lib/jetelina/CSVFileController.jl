"""
    module: CSVFileController

    read the upload csv file, then insert into DB.
"""
module CSVFileController

    using CSV
    using DataFrames
#    using SQLite
    using Genie, Genie.Renderer, Genie.Renderer.Json
    using JetelinaReadConfig, JetelinaLog
    using ExeSql, DBDataController

    """
        function read( csvfname::String )

    # Arguments
    - `csvfname: String`: csv file name. Expect string data of JetelinaFileUploadPath + <csv file name>.

    read csv file, then insert the csv data into DB.
    """
    function read( csvfname::String )       
        if debugflg
            debugmsg = "csv file: $csvfname"
            JetelinaLog.writetoLogfile( debugmsg )
        end

        # read line count number from the head of the csv file
        row::Int = 1
        df = CSV.read( csvfname, DataFrame, limit=row )

        if JetelinaDBtype == "postgresql"
            # Case in PostgreSQL
            DBDataController.dataInsertFromCSV( csvfname )
        elseif JetelinaDBtype == "mariadb"
        elseif JetelinaDBtype == "oracle"
        end
    end
end