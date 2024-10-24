require 'mime/types'

class Response
  attr_reader :status, :content, :content_type, :response
  
  def initialize(status, content, content_type="text/html")
    @status = status 
    @content = content 
    @content_type = content_type
    @response = ""
    @response += "HTTP/1.1 #{status}\r\n"
    @response += "Content-Type: #{content_type}\r\n"
    @response += "Content-Length: #{content.bytesize}\r\n"  # Include content length for proper serving
    @response += "\r\n"
    @response += content
  end

  def self.fromFile(path, status=200)
    extension = File.extname(path)

    content_type = MIME::Types.of(File.basename(path)).first.to_s

    # Use binary mode for non-text files, like PDFs and images
    file_mode = content_type.start_with?("text/") ? "r" : "rb"

    # Open and read the file content
    begin  
      file = File.open(path, file_mode)
      file_content = file.read
    rescue 
      return Response.new(404, "404 not found", "text/html")
    end

    # If it's a text file, normalize newlines
    if content_type == "text/html"
      file_content.gsub!(/\r?\n/, "\r\n")
    end

    return Response.new(status, file_content, content_type)
  end
end