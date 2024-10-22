class Request 
  attr_reader :headers, :method, :params, :resource, :version
  def initialize(request_string) 
    head_and_body = request_string.split("\n\n", 2)
    request_line_and_headers  = head_and_body[0].split("\n", 2)

    @method, @resource, @version = request_line_and_headers [0].split(" ")

    @headers = request_line_and_headers [1].split("\n").map { |header| header_name, header_value = header.split(": ", 2); [header_name, header_value]  }.to_h()
    
    resource_params = @resource.split("?")[1]

    @params = {}
    
    if !head_and_body[1].to_s.empty?
      @params = head_and_body[1].split("&").map { |param| param_name, param_value = param.split("="); [param_name, param_value] }.to_h()
    elsif resource_params
      @params = resource_params.split("&").map { |param| param_name, param_value = param.split("="); [param_name, param_value] }.to_h()
    end
  end
end