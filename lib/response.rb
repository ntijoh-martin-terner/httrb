# frozen_string_literal: true

require 'mime/types'
require 'json'
require 'erb'

module Httrb
  #
  # Response
  #
  class Response
    attr_reader :status, :headers, :body

    #
    # Initializes Response
    #
    # @param [Integer] status The status code of the response
    # @param [Hash<String, String>] headers The headers of the response
    # @param [String] body The body of the response
    #
    def initialize(status, headers = {}, body = '')
      @status = status
      @headers = headers
      @body = body
    end

    #
    # Converts the response to a string
    #
    # @return [String] The string representation of the response
    #
    def to_s
      response = "HTTP/1.1 #{@status}\r\n"
      @headers.each { |key, value| response += "#{key}: #{value}\r\n" }
      response += "Content-Length: #{body.bytesize}\r\n" unless body.empty?
      response += "\r\n"
      response += body
      response
    end

    #
    # Creates a response for redirecting
    #
    # @param [String] location The path to redirect to
    # @param [Integer] status The status of the redirection, can be: 301, 302, 307, or 308
    #
    # @return [Response] The created response
    #
    def self.redirect(location, status = 302)
      headers = { 'Location' => location, 'Content-Length' => '0' }
      new(status, headers, '')
    end

    #
    # Creates a simple response for a 404 status code
    #
    # @return [Response] The created response
    #
    def self.not_found
      new(404, { 'Content-Type' => 'text/html' }, '404 Not Found')
    end

    #
    # Creates a response with Content-Type and content based on the absolute path to a file
    #
    # @param [String] path The absolute path of the file
    # @param [Integer] status The status of the response
    #
    # @return [Response] The created response
    #
    def self.from_file(path, status = 200)
      content_type = MIME::Types.of(File.basename(path)).first.to_s
      file_mode = content_type.start_with?('text/') ? 'r' : 'rb'

      begin
        file = File.open(path, file_mode)
        content = file.read
        file.close
        headers = { 'Content-Type' => content_type }
        new(status, headers, content)
      rescue Errno::ENOENT
        Response.not_found
      end
    end

    #
    # Returns an erb response from erb path
    #
    # @param [String] file_path The file path to the erb file
    #
    # @return [Response] The created response
    #
    def self.erb(file_path, caller_binding)
      file = File.open(file_path)
      file_contents = file.read

      rhtml = ERB.new(file_contents).result(caller_binding)

      Httrb::Response.new(200, { 'Content-Type' => 'text/html' }, rhtml)
    end

    #
    # Creates a json response from a hash
    #
    # @param [Hash] data The json data of the response as a Hash
    # @param [Integer] status The status of the response
    #
    # @return [Response] The created response
    #
    def self.json(data, status = 200)
      headers = { 'Content-Type' => 'application/json' }
      body = data.to_json
      new(status, headers, body)
    end
  end
end
