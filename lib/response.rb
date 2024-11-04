require 'mime/types'

# class Response
#   attr_reader :status, :content, :content_type, :response
  
#   def initialize(status, content, content_type="text/html")
#     @status = status 
#     @content = content 
#     @content_type = content_type
#     @response = ""
#     @response += "HTTP/1.1 #{status}\r\n"
#     @response += "Content-Type: #{content_type}\r\n"
#     @response += "Content-Length: #{content.bytesize}\r\n"  # Include content length for proper serving
#     @response += "\r\n"
#     @response += content
#   end

#   # New method for handling HTTP redirects
#   def self.redirect(location, status=302)
#     response = ""
#     response += "HTTP/1.1 #{status}\r\n"
#     response += "Location: #{location}\r\n"
#     response += "Content-Length: 0\r\n"  # No content for redirect
#     response += "\r\n"
#     return Response.new(status, "", "text/html").tap do |r|
#       r.instance_variable_set(:@response, response)  # Set custom redirect response
#     end
#   end

#   def self.fromFile(path, status=200)
#     extension = File.extname(path)

#     content_type = MIME::Types.of(File.basename(path)).first.to_s

#     # Use binary mode for non-text files, like PDFs and images
#     file_mode = content_type.start_with?("text/") ? "r" : "rb"

#     # Open and read the file content
#     begin  
#       file = File.open(path, file_mode)
#       file_content = file.read
#     rescue 
#       return Response.new(404, "404 not found", "text/html")
#     end

#     # If it's a text file, normalize newlines
#     if content_type == "text/html"
#       file_content.gsub!(/\r?\n/, "\r\n")
#     end

#     return Response.new(status, file_content, content_type)
#   end

# end


class Response
  attr_reader :status, :headers, :body

  def initialize(status, headers={}, body="")
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
  def self.redirect(location, status=302)
    headers = { "Location" => location, "Content-Length" => "0" }
    new(status, headers, "")
  end

  def self.not_found()
    return new(404, { "Content-Type" => "text/html" }, "404 Not Found")
  end

  # Method to handle file serving for GET requests
  def self.from_file(path, status=200)
    content_type = MIME::Types.of(File.basename(path)).first.to_s
    file_mode = content_type.start_with?("text/") ? "r" : "rb"

    begin
      file = File.open(path, file_mode)
      content = file.read
      file.close
      headers = { "Content-Type" => content_type }
      new(status, headers, content)
    rescue Errno::ENOENT
      Response.not_found
    end
  end

  # Method to handle JSON responses (for APIs)
  def self.json(data, status=200)
    headers = { "Content-Type" => "application/json" }
    body = data.to_json
    new(status, headers, body)
  end
end
