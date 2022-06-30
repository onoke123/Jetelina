using Genie.Router
using DBDataController

route("/") do
  serve_static_file("welcome.html")
end

route( "/getalldbdata", DBDataController.getalldbdata )

route( "/showdbdata" ) do 
  serve_static_file( "showdbdata.html" )  
end