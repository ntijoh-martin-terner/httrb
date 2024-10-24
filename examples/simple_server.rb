require_relative "../lib/http_server"
require_relative "../lib/response"

server = HTTPServer.new(4567)

server.router.add_route("/") { "<h1>Hello, World!</h1>" }
server.router.add_route("/thing/") { "<h1>Thing!</h1>" }
server.router.add_content_route("/content/", ["../content/"])
server.router.add_content_route("/requests/", ["../spec/example_requests/", "../content/"])
server.router.add_content_route("/404/", ["./"])

server.start
server.router.add_content_route("/newcontent/", ["../content/"])
server.intercept_response = -> (response, request) { 
  if response.status != 404
    return response 
  end

  # return Response.new(404,"Custom 404 Not Found","text/html")
  current_file_dir = File.expand_path(File.dirname(__FILE__)) 
  
  # Join the current file directory with the relative path
  absolute_path = File.expand_path("./404.html", current_file_dir)

  p absolute_path
  p current_file_dir
  
  return Response.fromFile(absolute_path, 404)
}
# server.stop
sleep