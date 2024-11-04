# frozen_string_literal: true

require 'mime/types'
class Response
  attr_reader :status, :headers, :body

  def initialize(status, headers = {}, body = '')
    @status = status
    @headers = headers
    @body = body
  end

  def to_s
    response = "HTTP/1.1 #{@status}\r\n"
    @headers.each { |key, value| response += "#{key}: #{value}\r\n" }
    response += "Content-Length: #{body.bytesize}\r\n" unless body.empty?
    response += "\r\n"
    response += body
    response
  end

  # Method to handle GET requests, with the ability to serve static files or other content
  # def self.get(content, content_type="text/html", status=200)
  #   headers = { "Content-Type" => content_type }
  #   new(status, headers, content)
  # end

  # # Method to handle POST responses, assuming no content is returned
  # def self.post(status=201)
  #   headers = { "Content-Type" => "application/json" }  # Example for JSON responses
  #   new(status, headers, "")
  # end

  # Method to handle redirects for any HTTP method
  def self.redirect(location, status = 302)
    headers = { 'Location' => location, 'Content-Length' => '0' }
    new(status, headers, '')
  end

  def self.not_found
    new(404, { 'Content-Type' => 'text/html' }, '404 Not Found')
  end

  # Method to handle file serving for GET requests
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

  def self.json(data, status = 200)
    headers = { 'Content-Type' => 'application/json' }
    body = data.to_json
    new(status, headers, body)
  end
end
