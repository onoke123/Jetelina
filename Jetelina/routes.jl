using Genie.Router
using DBDataController
using JetelinaReadconfig

# welcome page
route("/") do
  serve_static_file("welcome.html")
end

# アップロードされたファイルのデータを表示し、データ編集するページ
route( "/edit" ) do
  serve_static_file( "data_edit.html" )
end

# DBから取得した全データをjsonで返すサンプル
route( "/getalldbdata", DBDataController.getalldbdata )

route( "/showdbdata" ) do 
  serve_static_file( "showdbdata.html" )  
end