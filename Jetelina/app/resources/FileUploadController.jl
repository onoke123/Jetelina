"""
module: FileUploadController

Author: Ono keiji
Version: 1.0
Description:
	csv file upload controller

functions
	read(csvfname::String) read csv file, then insert the csv data into DB.
	fup() upload the csv file from fileuplaod.html.
"""
module FileUploadController

using Genie, Genie.Requests
using CSV, DataFrames
using Jetelina.JLog, Jetelina.DBDataController, Jetelina.JMessage
import Jetelina.CallReadConfig.ReadConfig as j_config

JMessage.showModuleInCompiling(@__MODULE__)

export read, fup

"""
function read( csvfname::String )

	read csv file, then insert the csv data into DB.


# Arguments
- `csvfname: String`: csv file name. Expect string data of JetelinaFileUploadPath + <csv file name>.
"""
function read(csvfname::String)
	# read line count number from the head of the csv file
	row::Int = 1
	df = CSV.read(csvfname, DataFrame, limit = row)

	#===
		Tips:
			CSV files must have 'jt_id' name in its column.
			This is the protocol.
	===#
	if ("jt_id" ∉ names(df))
		return false
	else
		return DBDataController.dataInsertFromCSV(csvfname)
	end
end

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
			csvfilename = joinpath(@__DIR__, j_config.JetelinaFileUploadPath, f[2].name)
			write(csvfilename, f[2].data)
		end

		if length(files) == 0
			@info "FileUploadController.fup() No file uploaded"
		end

		read(csvfilename)
	else
		"No file uploaded"
	end
end
end
