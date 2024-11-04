require_relative "../../lib/http_server"
require_relative "../../lib/response"

server = HTTPServer.new(4567)

server.router.add_route("/") { Response.new(200, { "Content-Type" => "text/html" }, "<h1>Hello, World!</h1>") }
server.router.add_directory_route("/favicon/", ["./content/favicon/"])
server.router.add_file_route("/favicon.ico", "./content/favicon/favicon.ico")
server.router.add_directory_route("/404/", ["./404/"])

server.start
server.router.add_directory_route("/newcontent/", ["./content/"])
server.intercept_response = -> (response, request) { 
  if response.status != 404
    return response 
  end

  # current_file_dir = File.expand_path(File.dirname(__FILE__)) 
  
  # absolute_path = File.expand_path("./404.html", current_file_dir)
  
  # return Response.from_file(absolute_path, 404)
  return Response.redirect("/404/404.html", 302)
}

sleep