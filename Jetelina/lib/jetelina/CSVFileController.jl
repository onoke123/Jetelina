"""
    module: CSVFileController

    read the upload csv file, then insert into DB.
"""
module CSVFileController

    using CSV
    using DataFrames
    using SQLite
    using Genie, Genie.Renderer, Genie.Renderer.Json
    using JetelinaReadConfig, JetelinaLog
    using ExeSql, DBDataController

    """
        function read( csvfname::String )

    # Arguments
    - `csvfname: String`: csv file name

    read csv file, then insert the csv data into DB.
    """
    function read( csvfname::String )       
        if debugflg
            debugmsg = "csv file: $csvfname"
            writetoLogfile( debugmsg )
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

        #　Dataを表示しているだけ
        #json( Dict( "Jetelina" => copy.( eachrow( df ))))

    end
end