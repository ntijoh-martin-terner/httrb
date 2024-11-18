# frozen_string_literal: true

require_relative 'router_helper'
require_relative 'response'
require 'pathname'

# Httrb
module Httrb
  # Router
  class Router
    include RouterHelper

    def initialize
      @routes = Hash.new { |hash, key| hash[key] = {} }
    end

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

    def add_directory_route(path_alias, method, paths)
      current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

      patterns = expand_directory_glob_patterns(paths, current_file_dir)

      path_alias_route = @routes[path_alias]

      raise StandardError, 'Route alias already exists' if path_alias_route && path_alias_route[method]

      path_alias_route[method] = { type: :directory, patterns:, action: nil }
    end

    def add_route(path_alias, method, &action)
      # check if it exists
      @routes[path_alias][method] = { type: :route, action: }
    end

    def get_matching_route(request)
      request_path = request.path
      request_method = request.method

      @routes.each do |route_path, methods|
        route = methods[request_method]

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
