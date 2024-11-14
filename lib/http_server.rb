# frozen_string_literal: true

require_relative 'request'
require_relative 'response'
require_relative 'router'
require 'socket'

module Httrb
  # HTTPServer
  class HTTPServer
    attr_reader :router, :port, :server
    attr_accessor :intercept_response

    def initialize(port)
      @port = port
      @server = nil
      @router = Router.new
      @thread = nil
      @intercept_response = ->(response, _) { response }
    end

    def start
      @server = TCPServer.new(@port)
      puts "Listening on #{@port}"

      @thread = Thread.new do
        while (session = @server.accept)
          data = ''
          while (line = session.gets) && line !~ /^\s*$/
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
      p 'stopping'
      @thread&.kill # Kill the server thread
      @server&.close # Close the TCPServer instance if it exists
    end
  end
end
