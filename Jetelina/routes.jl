using Genie.Router
using DataController

route("/") do
  serve_static_file("welcome.html")
end

route( "/dbdata", DataController.getalldata )