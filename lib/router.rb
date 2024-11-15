# frozen_string_literal: true

require_relative 'response'
require 'pathname'

# Httrb
module Httrb
  # Router
  class Router
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

      raise StandardError, 'Route alias already exists' if @routes[path_alias] && @routes[path_alias][method]

      @routes[path_alias][method] = { type: :directory, patterns:, action: nil }
    end

    def expand_directory_glob_patterns(paths, current_file_dir)
      patterns = {}

      paths.each do |path|
        # Join the current file directory with the relative path
        absolute_path = if File.directory?(path)
                          path
                        else
                          File.expand_path(path, current_file_dir)
                        end

        relative_base_path = path.sub(/\*.*$/, '') + Pathname::SEPARATOR_LIST # remove glob patterns from path

        absolute_base_path = File.realpath(File.expand_path(relative_base_path, current_file_dir))

        raise StandardError, 'Directory router cannot serve file' if File.file?(absolute_base_path)

        expanded_patterns = Dir[File.directory?(absolute_path) ? File.join(absolute_path, '**', '*') : absolute_path]

        patterns[absolute_base_path] = expanded_patterns
      end

      patterns
    end

    def add_route(path_alias, method, &action)
      # check if it exists
      @routes[path_alias][method] = { type: :route, action: }
    end

    def get_request_variables(route_path, request_path)
      request_sections = request_path.split('/')

      route_path_sections = route_path.split('/')

      return nil unless request_sections.length == route_path_sections.length

      request_variables = []
      match = true

      route_path_sections.each_with_index do |section, index|
        request_section = request_sections[index]

        if section[0] == ':'
          request_variables.append(request_section)
        elsif request_section != section
          match = false
          break
        end
      end

      return request_variables if match

      nil
    end

    def get_matching_pattern(patterns, route_path, request_path)
      patterns.each do |base_path, expanded_paths|
        relative_request_path = request_path.split(route_path)[1]

        next if relative_request_path.nil?

        expanded_request_path = File.join(base_path, relative_request_path)

        next unless expanded_paths.include? expanded_request_path

        return expanded_request_path
      end

      nil
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

          return { route: route, pattern: pattern, type: :dynamic } unless pattern.nil?
        when :file, :route
          variables = get_request_variables(route_path, request_path)

          return { route: route, variables: variables, type: :static } unless variables.nil?
        else
          next
        end
      end

      nil
    end

    def match_route(request)
      # Extract the path from the request
      result = get_matching_route(request)

      return Response.not_found if result.nil?

      result_route = result[:route]

      case result[:type]
      when :static
        case result_route[:type]
        when :route
          return result_route[:action].call(request, result[:variables])
        when :file
          return Response.from_file(result_route[:file_path])
        end
      when :dynamic
        return Response.from_file(result[:pattern])
      end

      Response.not_found
    end
  end
end
