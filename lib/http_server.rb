require_relative 'request'
require_relative 'response'
require_relative 'router'
require 'socket'

class HTTPServer
    attr_reader :router, :port, :server
    def initialize(port)
        @port = port
        @server = nil
        @router = Router.new
        @thread = nil
    end

    def start
        @server = TCPServer.new(@port)
        puts "Listening on #{@port}"

        # @router.add_route("/") { "<h1>Hello, World!</h1>" }
        # @router.add_route("/thing/") { "<h1>Thing!</h1>" }
        # @router.add_content_route("/content/", ["../content/"])
        # @router.add_content_route("/requests/", ["../spec/example_requests/", "../content/"])

        @thread = Thread.new do
            while session = @server.accept
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

        # trap("INT") do
        #     p "stopping"
        #     @thread.kill if @thread  # Kill the server thread
        #     @server.close if @server  # Close the TCPServer instance if it exists
        #     exit
        # end

        # sleep
    end

    def stop
        p "stopping"
        @thread.kill if @thread  # Kill the server thread
        @server.close if @server  # Close the TCPServer instance if it exists
    end
end

# server = HTTPServer.new(4567)
# server.start
# server.stop
# sleep