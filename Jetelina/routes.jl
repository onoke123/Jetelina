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

#=== アップロードされたファイルのデータを表示し、データ編集するページ
route( "/edit" ) do
  serve_static_file( "jetelina/data_edit.html" )
end
===#

# DBから取得した全データをjsonで返す
#route( "/getalldbdata", DBDataController.getalldbdata )

# DBから取得した全tableをjsonで返す
route( "/getalldbtable", GetDataController.getTableList )

# 指定されたtableをdropする
route( "/deletetable", PostDataController.deleteTable, method = POST )

# 指定されたtableのカラムをjsonで返す
route( "getcolumns", PostDataController.getColumns, method = POST )

# API(SQL) Listをjsonで返す
route( "getapilist", PostDataController.getApiList, method = POST )

route( "/showdbdata" ) do 
  serve_static_file( "jetelina/showdbdata.html" )  
end

# csvファイルを読み込んで画面に表示する
route( "/getcsvdata", CSVFileController.read )

# db table columns の選択されたpost dataを取得
route( "/putitems", PostDataController.postDataAcquire, method = POST )

#== file upload
route( "/fileupload" ) do
  serve_static_file( "jetelina/fileupload.html" ) 
end
===#
route("/dofup", FileUploadController.fup, method = POST)

# test for three.js
#===
route( "/3" ) do
  serve_static_file( "jetelina/3d4jet.html")
end
===#
# SQL analyze data を取得する
#route( "/getanalyzedata", SQLAnalyzer.getAnalyzeData )

# chat 
route( "/jetelinawords", PostDataController.addJetelinaWords, method = POST)
