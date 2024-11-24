# frozen_string_literal: true

require_relative 'router_helper'
require_relative 'response'
require 'pathname'

module Httrb
  #
  # Router
  #
  class Router
    include RouterHelper

    #
    # Initializes Router
    #
    def initialize
      @routes = Hash.new { |hash, key| hash[key] = {} }
    end

    #
    # Adds a file route to the router
    #
    # This method allows you to map a specific file to a route alias and HTTP method
    # The route will serve the content of the specified file when accessed
    #
    # @param [String] path_alias The alias path for the route
    # @param [String] method The HTTP method for the route
    # @param [String] path The path to the file to be served. Can be relative or absolute.
    #
    # @raise [StandardError] If the provided path is a directory instead of a file.
    #
    # @example Adding a file route
    #   router = Router.new
    #   router.add_file_route('/example', 'GET', './files/example.txt')
    #
    #   # The above will serve the content of `example.txt` at `/example` for GET requests.
    #
    def add_file_route(path_alias, method, path)
      current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

      absolute_base_path = if File.file?(path)
                             path
                           else
                             File.realpath(File.expand_path(path, current_file_dir))
                           end

      raise StandardError, 'File router cannot serve directory' if File.directory?(absolute_base_path)

      @routes[path_alias][method] = { type: :file, file_path: absolute_base_path, action: nil }
    end

    #
    # Adds a directory route to the router
    #
    # This method allows you to map several directories to a route alias and HTTP method
    # The route will serve the content of the specified file when accessed
    # If there is a collision between the provided directories then behavior is undefined
    #
    # @param [String] path_alias The alias path for the route
    # @param [String] method The HTTP method for the route
    # @param [String] paths The paths to the directories to be served.
    #
    # @raise [StandardError] If the provided route alias is already assigned to the same method.
    #
    # @example Adding a directory route
    #   router = Router.new
    #   router.add_directory_route('/example', 'GET', ['./path1', '../path2/path3/'])
    #
    #   # The above will serve the contents of `./path1` and `../path2/path3` at `/example` for GET requests.
    #
    def add_directory_route(path_alias, method, paths)
      current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

      patterns = expand_directory_glob_patterns(paths, current_file_dir)

      path_alias_route = @routes[path_alias]

      raise StandardError, 'Route alias already exists' if path_alias_route && path_alias_route[method]

      path_alias_route[method] = { type: :directory, patterns:, action: nil }
    end

    #
    # Adds a block based route to the router
    #
    # @param [String] path_alias The alias path for the route
    # @param [String] method The HTTP method for the route
    # @param [Proc] action The code to run when the route is matched, should return the response of the route.
    #
    # @raise [StandardError] If the provided route alias is already assigned to the same method.
    #
    # @example Adding a block based route
    #   server.router.add_route('/', 'GET') do
    #     Httrb::Response.new(200, { 'Content-Type' => 'text/html' }, '<h1>Hello, World!</h1>')
    #   end
    #
    def add_route(path_alias, method, &action)
      # check if it exists
      path_alias_route = @routes[path_alias]
      raise StandardError, 'Route alias already exists' if path_alias_route && path_alias_route[method]

      @routes[path_alias][method] = { type: :route, action: }
    end

    #
    # Gets the matching route for the request or returns nil if there is none
    #
    # @param [Request] request The request to match
    #
    # @return [Hash, nil] route
    #
    # @private
    #
    def get_matching_route(request)
      request_path = request.path
      request_method = request.method

      @routes.each do |route_path, methods|
        route = methods[request_method]

        next unless route

        case route[:type]
        when :directory
          patterns = route[:patterns]

          pattern = get_matching_pattern(patterns, route_path, request_path)

          return { route: route, pattern: pattern, type: :dynamic } if pattern
        when :file, :route
          variables = get_request_variables(route_path, request_path)

          return { route: route, variables: variables, type: :static } if variables
        else
          next
        end
      end

      nil
    end

    #
    # Gets the matched route response for the request
    #
    # @param [Request] request The request to match
    #
    # @return [Response] response
    #
    def match_route(request)
      # Extract the path from the request
      result = get_matching_route(request)

      case result
      in { type: :static, route: { type: :route, action: }, variables: }
        action.call(request, variables)
      in { type: :static, route: { type: :file, file_path: } }
        Response.from_file(file_path)
      in { type: :dynamic, pattern: }
        Response.from_file(pattern)
      else
        Response.not_found
      end
    end
  end
end
