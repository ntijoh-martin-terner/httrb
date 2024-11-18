# frozen_string_literal: true

require_relative 'request'
require_relative 'response'
require_relative 'router'
require 'socket'

module Httrb
  # HTTPServer
  class HTTPServer
    attr_reader :router, :port, :server
    attr_accessor :intercept_response, :intercept_request

    def initialize(port)
      @port = port
      @server = nil
      @router = Router.new
      @thread = nil
      @intercept_response = ->(response, _) { response }
      @intercept_request = ->(request) { request }
    end

    def read_raw(session)
      raw_request = ''

      # Read headers
      while (line = session.gets) && line !~ /^\s*$/
        raw_request += line
      end

      # Get content length and read the body if needed
      content_length = raw_request[/Content-Length: (\d+)/i, 1].to_i
      if content_length.positive?
        raw_request += "\r\n"
        raw_request += session.read(content_length) # Read the body based on the Content-Length
      end

      raw_request
    end

    def start
      @server = TCPServer.new(@port)
      puts "Listening on #{@port}"

      @thread = Thread.new do
        while (session = @server.accept)
          raw_request = read_raw(session)

          request = Request.new(raw_request)

          request = @intercept_request.call(request)

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
