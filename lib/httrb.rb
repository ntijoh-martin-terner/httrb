# frozen_string_literal: true

require_relative './http_server'
require_relative './response'
require_relative './router'
require_relative './request'

#
# Httrb: A simple HTTP server framework
#
# This module provides a lightweight, Sinatra-like framework for creating
# HTTP servers in Ruby. It handles routing, requests, and responses, and
# allows you to define custom behavior for your HTTP server.
#
# Features:
# - Easy route definition
# - Lightweight and configurable
#
# @example
#   Httrb.get('/foo/:variable/:second/') do | variable, second |
#     # Your route logic here
#   end
#
module Httrb
  @server = HTTPServer.new(4567)
  @before_filter = nil
  @after_filter = nil

  #
  # RequestContext
  #
  # @private
  #
  class RequestContext
    attr_accessor :request, :response, :variables, :params

    def initialize(request, response, variables)
      @request = request
      @params = @request.params
      @response = response
      @variables = variables
    end
  end

  #
  # Adds a route to the server
  #
  # @param [String] path path alias for the route
  # @param [String] method matching method for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  # @private
  #
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

  #
  # Adds a get route to the server
  #
  # @param [<Type>] path path path alias for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  def self.get(path, &block)
    add_route(path, 'GET', &block)
  end

  #
  # Adds a post route to the server
  #
  # @param [<Type>] path path path alias for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  def self.post(path, &block)
    add_route(path, 'POST', &block)
  end

  #
  # Adds a put route to the server
  #
  # @param [<Type>] path path path alias for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  def self.put(path, &block)
    add_route(path, 'PUT', &block)
  end

  #
  # Adds a delete route to the server
  #
  # @param [<Type>] path path path alias for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  def self.delete(path, &block)
    add_route(path, 'DELETE', &block)
  end

  #
  # Adds a patch route to the server
  #
  # @param [<Type>] path path path alias for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  def self.patch(path, &block)
    add_route(path, 'PATCH', &block)
  end

  #
  # Adds an options route to the server
  #
  # @param [<Type>] path path path alias for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  def self.options(path, &block)
    add_route(path, 'OPTIONS', &block)
  end

  #
  # Adds a link route to the server
  #
  # @param [<Type>] path path path alias for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  def self.link(path, &block)
    add_route(path, 'LINK', &block)
  end

  #
  # Adds an unlink route to the server
  #
  # @param [<Type>] path path path alias for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  def self.unlink(path, &block)
    add_route(path, 'UNLINK', &block)
  end

  #
  # Adds a route applying to any method to the server
  #
  # @param [<Type>] path path path alias for the route
  # @param [Proc] block The code to execute when the route is matched.
  #
  def self.any(path, &block)
    %w[GET POST PUT DELETE PATCH OPTIONS LINK UNLINK].each do |method|
      add_route(path, method, &block)
    end
  end

  #
  # Adds a before filter which will run before a route gets matched
  #
  # @param [Proc] filter The code to execute when a request is made
  #
  def self.before(&filter)
    @before_filter = filter
  end

  #
  # Adds an after filter which will run after a route gets matched
  #
  # @param [Proc] filter The code to execute before a response is sent
  #
  def self.after(&filter)
    @after_filter = filter
  end

  #
  # Intercepts a response and runs the 'after' filter on it
  #
  # @param [Response] response Response class
  # @param [Request] request Request class
  #
  # @private
  #
  def self.intercept_response(response, request)
    # return response if response.status != 404
    context = RequestContext.new(request, response, nil)

    context.instance_eval(&@after_filter) if @after_filter

    context.response
  end

  #
  # Starts the server
  #
  def self.start
    @server.intercept_response = method(:intercept_response)

    current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

    absolute_base_path = File.expand_path('./public/', current_file_dir)

    @server.router.add_directory_route('/public/', 'GET', [absolute_base_path]) if File.directory?(absolute_base_path)

    @server.start
    sleep
  end
end
