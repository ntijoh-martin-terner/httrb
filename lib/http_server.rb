# frozen_string_literal: true

require_relative 'request'
require_relative 'response'
# require_relative 'router'
require_relative 'radix_tree'
require 'socket'

module Httrb
  #
  # HTTPServer
  #
  class HTTPServer
    attr_reader :router, :port, :server
    attr_accessor :intercept_response, :intercept_request

    #
    # Initializes HTTPServer
    #
    # @param [Integer] port The port of the server
    #
    def initialize(router, routing_tree = RadixTree)
      @server = nil
      @router = router.new(routing_tree)
      @thread = nil
      @intercept_response = ->(response, _) { response }
      @intercept_request = ->(request) { request }
    end

    #
    # Resets the router
    #
    def clear_routes
      @router.clear_routes
    end

    #
    # Reads the session response, including content
    #
    # @param [String] session <description>
    #
    # @return [String] The raw request
    #
    # @private
    #
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

    #
    # Starts the http server
    #
    # @param [Integer] port The port of the server
    #
    def start(port)
      @port = port

      @server = TCPServer.new(@port)
      puts "Listening on #{@port}"

      @thread = Thread.new do
        loop { handle_session(@server.accept) }
      end
    end

    #
    # Handles a session
    #
    # @param [TCPSocket] session session
    #
    # @private
    #
    def handle_session(session)
      raw_request = read_raw(session)

      request = Request.new(raw_request)

      request = @intercept_request.call(request)

      response = @router.match_route(request)

      response = @intercept_response.call(response, request)

      session.print response.to_s
      session.close
    end

    #
    # Stops the http server
    #
    def stop
      p 'stopping'
      @thread&.kill # Kill the server thread
      @server&.close # Close the TCPServer instance if it exists
    end
  end
end
