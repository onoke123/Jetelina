using Genie.Router
using DBDataController, CSVFileController, PostDataController, FileUploadController
using JetelinaReadConfig

# welcome page
route("/") do
  serve_static_file("welcome.html")
end

# Jetelina dashboard page
route("/jetelina") do
  serve_static_file("jetelina/jetelina_dashboard.html")
end

#=== アップロードされたファイルのデータを表示し、データ編集するページ
route( "/edit" ) do
  serve_static_file( "jetelina/data_edit.html" )
end
===#

# DBから取得した全データをjsonで返す
#route( "/getalldbdata", DBDataController.getalldbdata )

# DBから取得した全tableをjsonで返す
route( "/getalldbtable", DBDataController.getTableList )

route( "/showdbdata" ) do 
  serve_static_file( "jetelina/showdbdata.html" )  
end

# csvファイルを読み込んで画面に表示する
route( "/getcsvdata", CSVFileController.read );

# post dataを取得
route( "/putitems", PostDataController.get, method = POST );

#== file upload
route( "/fileupload" ) do
  serve_static_file( "jetelina/fileupload.html" ) 
end
===#
route("/dofup", FileUploadController.fup, method = POST);
