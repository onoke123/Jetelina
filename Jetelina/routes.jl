using Genie.Router
using DBDataController, CSVFileController, PostDataController
using JetelinaReadConfig

# welcome page
route("/") do
  serve_static_file("welcome.html")
end

# アップロードされたファイルのデータを表示し、データ編集するページ
route( "/edit" ) do
  serve_static_file( "jetelina/data_edit.html" )
end

# DBから取得した全データをjsonで返すサンプル
route( "/getalldbdata", DBDataController.getalldbdata )

route( "/showdbdata" ) do 
  serve_static_file( "jetelina/showdbdata.html" )  
end

# csvファイルを読み込んで画面に表示する
route( "/getcsvdata", CSVFileController.read );

# post dataを取得
route( "/putitems", PostDataController.get, method = POST );