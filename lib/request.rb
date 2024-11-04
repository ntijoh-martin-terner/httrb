# frozen_string_literal: true

# Request
class Request
  attr_reader :headers, :method, :params, :resource, :version

  def initialize(request_string)
    head, body = request_string.split("\n\n", 2)
    request_line, headers = head.split("\n", 2)

    @method, @resource, @version = request_line.split(' ')

    @headers = parse_headers(headers)

    @params = parse_params(body, request_line)
  end

  def parse_headers(headers)
    headers.split("\n").map do |header|
      header_name, header_value = header.split(': ', 2)
      [header_name, header_value]
    end.to_h
  end

  def parse_params(body, request_line)
    resource = request_line.split(' ')[1]
    resource_params = resource.split('?')[1]

    if !body.to_s.empty?
      parse_head_params(body)
    elsif resource_params
      parse_resource_params(resource_params)
    end
  end

  def parse_resource_params(resource_params)
    resource_params.split('&').map do |param|
      param_name, param_value = param.split('=')
      [param_name, param_value]
    end.to_h
  end

  def parse_head_params(head)
    head.split('&').map do |param|
      param_name, param_value = param.split('=')
      [param_name, param_value]
    end.to_h
  end
end
