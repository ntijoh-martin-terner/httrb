require_relative 'request'
require_relative 'response'
require_relative 'router'
require 'socket'

class HTTPServer

    def initialize(port)
        @port = port
        @router = Router.new
    end

    def start
        server = TCPServer.new(@port)
        puts "Listening on #{@port}"
        #router.add_route...
        
        def fun()
                    
            html = "<h1>Hello, World!</h1>"
            return html
        end

        @router.add_route("/") { "<h1>Hello, World!</h1>" }
        @router.add_content_route("/content/", "../content/")

        while session = server.accept
            data = ""
            while line = session.gets and line !~ /^\s*$/
                data += line
            end

            request = Request.new(data)

            response = @router.match_route(request)
            
            session.print response.response
            session.close
        end
    end
end

server = HTTPServer.new(4567)
server.start