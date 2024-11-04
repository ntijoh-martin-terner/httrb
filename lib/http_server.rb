require_relative 'request'
require_relative 'response'
require_relative 'router'
require 'socket'

class HTTPServer
    attr_reader :router, :port, :server
    attr_accessor :intercept_response
    def initialize(port)
        @port = port
        @server = nil
        @router = Router.new
        @thread = nil
        @intercept_response = -> (response, _) { response }
    end

    def start
        @server = TCPServer.new(@port)
        puts "Listening on #{@port}"

        @thread = Thread.new do
            while session = @server.accept
                data = ""
                while line = session.gets and line !~ /^\s*$/
                    data += line
                end

                request = Request.new(data)

                response = @router.match_route(request)

                response = @intercept_response.call(response, request)
                
                session.print response.to_s
                session.close
            end
        end
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