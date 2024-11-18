# frozen_string_literal: true

module Httrb
  # Request
  class Request
    attr_reader :headers, :method, :params, :resource, :version, :path

    def initialize(request_string)
      head, body = request_string.split("\r\n\r\n", 2)
      request_line, headers = head.split("\r\n", 2)

      @method, @resource, @version = request_line.split(' ')

      @path = @resource.split('?').first

      @headers = Request.parse_headers(headers)

      @params = Request.parse_params(body, @resource)
    end

    def self.parse_headers(headers)
      headers.split("\r\n").map do |header|
        header_name, header_value = header.split(': ', 2)
        [header_name, header_value]
      end.to_h
    end

    def self.parse_params(body, resource)
      resource_params = resource.split('?')[1]

      if !body.to_s.empty?
        Request.parse_raw_params(body)
      elsif resource_params
        Request.parse_raw_params(resource_params)
      else
        {}
      end
    end

    def self.parse_raw_params(param_string)
      param_string.split('&').map do |param|
        param_name, param_value = param.split('=')
        [param_name, param_value]
      end.to_h
    end
  end
end
