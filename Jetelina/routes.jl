using Genie.Router
using DBDataController
using JetelinaReadconfig

#Genie初期化時に自動実行
JetelinaReadconfig.ini()

route("/") do
  serve_static_file("welcome.html")
end

route( "/getalldbdata", DBDataController.getalldbdata )

route( "/showdbdata" ) do 
  serve_static_file( "showdbdata.html" )  
end