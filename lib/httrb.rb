# frozen_string_literal: true

require_relative './http_server'
require_relative './response'
require_relative './router'
require_relative './request'

# Httrb
module Httrb
  @server = HTTPServer.new(4567)
  @before_filters = []

  # Define a 'get' method to register routes
  def self.get(path, &block)
    @server.router.add_route(path, 'GET', &block)
  end

  def self.post(path, &block)
    @server.router.add_route(path, 'POST', &block)
  end

  def self.put(path, &block)
    @server.router.add_route(path, 'PUT', &block)
  end

  def self.delete(path, &block)
    @server.router.add_route(path, 'DELETE', &block)
  end

  def self.patch(path, &block)
    @server.router.add_route(path, 'PATCH', &block)
  end

  def self.options(path, &block)
    @server.router.add_route(path, 'OPTIONS', &block)
  end

  def self.link(path, &block)
    @server.router.add_route(path, 'LINK', &block)
  end

  def self.unlink(path, &block)
    @server.router.add_route(path, 'UNLINK', &block)
  end

  # Define a method to add before filters
  def self.before(&filter)
    @before_filters << filter
  end

  def self.start
    @server.intercept_response = lambda { |response, request|
      @before_filters.each do |filter|
        instance_exec(request, response, &filter)
      end

      return response if response.status != 404

      Response.not_found
    }

    # current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

    # absolute_base_path = File.realpath(File.expand_path('./public/', current_file_dir))

    # @server.router.add_directory_route('/public/', 'GET', [absolute_base_path])
    @server.start
    sleep
  end
end
