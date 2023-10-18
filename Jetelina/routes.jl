using Genie.Router
using DBDataController, CSVFileController, PostDataController, GetDataController, FileUploadController, SQLAnalyzer
using JetelinaReadConfig

# welcome page
route("/") do
  serve_static_file("welcome.html")
end

# Jetelina dashboard page
route("/jetelina") do
  serve_static_file("jetelina/jetelina_dashboard.html")
end

# Jetelina dashboard2 page
route("/jetelina2") do
  serve_static_file("jetelina/jetelina_dashboard2.html")
end

route("/chkacount", PostDataController.login, method = POST )

# returns table list data in Json
route( "/getalldbtable", GetDataController.getTableList )

# drops table by ordering
route( "/deletetable", PostDataController.deleteTable, method = POST )

# returns column list ordered by table in Json
route( "getcolumns", PostDataController.getColumns, method = POST )

# returns API(SQL) list in Json
route( "getapilist", PostDataController.getApiList, method = POST )

# delete api from  JetelinaSQLListfile file
route("/deleteapi", PostDataController.deleteApi, method = POST)

route( "/showdbdata" ) do 
  serve_static_file( "jetelina/showdbdata.html" )  
end

# reads uploaded csv file
route( "/getcsvdata", CSVFileController.read )

# db table columns の選択されたpost dataを取得
route( "/putitems", PostDataController.postDataAcquire, method = POST )

# csv file upload and insert to DB
route("/dofup", FileUploadController.fup, method = POST)

# gets 'table combination vs access' relation data in condition panel
route("/gettablecombivsaccessrelationdata",GetDataController.getTableCombiVsAccessRelationData)
# gets sql performance data in condition panel
route("/getsqlaccessdata",GetDataController.getSqlAccessData)
route("/getperformancedata_real",GetDataController.getPerformanceRealData)
route("/getperformancedata_test",GetDataController.getPerformanceTestData)
route("/chkexistimprapifile",GetDataController.checkExistImproveApiFile)

# chat 
route( "/jetelinawords", PostDataController._addJetelinaWords, method = POST)
