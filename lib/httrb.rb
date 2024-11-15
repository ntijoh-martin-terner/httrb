# frozen_string_literal: true

require_relative './http_server'
require_relative './response'
require_relative './router'
require_relative './request'

# Httrb
module Httrb
  @server = HTTPServer.new(4567)
  @before_filter = nil
  @after_filter = nil

  # RequestContext
  class RequestContext
    attr_accessor :request, :response, :variables, :params

    def initialize(request, response, variables)
      @request = request
      @params = @request.params
      @response = response
      @variables = variables
    end
  end

  def self.add_route(path, method, &block)
    @server.router.add_route(path, method) do |request, variables|
      # Create a new context for each request
      context = RequestContext.new(request, nil, variables)

      # Execute all before filters in the context
      # @before_filters.each do |filter|
      #   context.instance_eval(&filter) # this does not intercept non existent routes... :(
      # end

      context.instance_exec(&@before_filter) if @before_filter

      # Execute the route block in the same context
      # next context.instance_eval(&block)
      next context.instance_exec(*variables, &block)
    end
  end

  # Define a 'get' method to register routes
  def self.get(path, &block)
    add_route(path, 'GET', &block)
  end

  def self.post(path, &block)
    add_route(path, 'POST', &block)
  end

  def self.put(path, &block)
    add_route(path, 'PUT', &block)
  end

  def self.delete(path, &block)
    add_route(path, 'DELETE', &block)
  end

  def self.patch(path, &block)
    add_route(path, 'PATCH', &block)
  end

  def self.options(path, &block)
    add_route(path, 'OPTIONS', &block)
  end

  def self.link(path, &block)
    add_route(path, 'LINK', &block)
  end

  def self.unlink(path, &block)
    add_route(path, 'UNLINK', &block)
  end

  def self.any(path, &block)
    %w[GET POST PUT DELETE PATCH OPTIONS LINK UNLINK].each do |method|
      add_route(path, method, &block)
    end
  end

  # Define a method to add before filters
  def self.before(&filter)
    @before_filter = filter
  end

  def self.after(&filter)
    @after_filter = filter
  end

  def router
    @router
  end

  # def self.intercept_request(request)
  #   return response if response.status != 404

  #   context = RequestContext.new(request, nil, nil)

  #   context.instance_eval(&@before_filter) # TODO: add more functionality

  #   context.request
  #   # Response.not_found
  # end

  def self.intercept_response(response, request)
    # return response if response.status != 404
    context = RequestContext.new(request, response, nil)

    context.instance_eval(&@after_filter) # TODO: add more functionality

    context.response
  end

  def self.start
    # @server.intercept_request = method(:intercept_request)
    @server.intercept_response = method(:intercept_response)

    current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

    absolute_base_path = File.expand_path('./public/', current_file_dir)

    @server.router.add_directory_route('/public/', 'GET', [absolute_base_path]) if File.directory?(absolute_base_path)

    @server.start
    sleep
  end
end
