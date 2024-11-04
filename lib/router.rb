# frozen_string_literal: true

require_relative 'response'
require 'pathname'

# Router
class Router
  def initialize
    @routes = {}
  end

  def add_file_route(path_alias, path)
    current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

    absolute_base_path = File.realpath(File.expand_path(path, current_file_dir))

    raise StandardError, 'File router cannot serve directory' if File.directory?(absolute_base_path)

    @routes[path_alias] = { type: :file, file_path: absolute_base_path, action: nil }
  end

  def add_directory_route(path_alias, paths)
    current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

    patterns = expand_directory_glob_patterns(paths, current_file_dir)

    raise StandardError, 'Route alias already exists' if @routes.key? path_alias

    @routes[path_alias] = { type: :directory, patterns:, action: nil }
  end

  def expand_directory_glob_patterns(paths, current_file_dir)
    patterns = {}

    paths.each do |path|
      # Join the current file directory with the relative path
      absolute_path = File.expand_path(path, current_file_dir)

      # relative_base_path = Pathname.new(path).dirname.to_s + Pathname::SEPARATOR_LIST
      relative_base_path = path.sub(/\*.*$/, '') + Pathname::SEPARATOR_LIST # remove glob patterns from path

      absolute_base_path = File.realpath(File.expand_path(relative_base_path, current_file_dir))

      raise StandardError, 'Directory router cannot serve file' if File.file?(absolute_base_path)

      expanded_patterns = Dir[File.directory?(absolute_path) ? File.join(absolute_path, '**', '*') : absolute_path]

      patterns[absolute_base_path] = expanded_patterns
    end

    patterns
  end

  def add_route(path_alias, &action)
    # check if it exists
    @routes[path_alias] = { type: :route, action: }
  end

  def match_static_route(request_path)
    return unless @routes.key?(request_path)

    static_route = @routes[request_path]
    if static_route[:type] == :route
      # Call the action for this route and return its result
      @routes[request_path][:action].call
    elsif static_route[:type] == :file
      Response.from_file(static_route[:file_path])
    end
  end

  def match_dynamic_route(request_path)
    @routes.each do |route_path, route|
      next if route[:type] != :directory

      patterns = route[:patterns]
      # base_path = route[:basePath]

      patterns.each do |base_path, expanded_paths|
        relative_request_path = request_path.split(route_path)[1]

        next if relative_request_path.nil?

        expanded_request_path = File.join(base_path, relative_request_path)

        next unless expanded_paths.include? expanded_request_path

        return Response.from_file(expanded_request_path)
      end
    end

    Response.not_found
  end

  def match_route(request)
    # Extract the path from the request
    request_path = request.resource

    return match_static_route(request_path) if @routes.key?(request_path)

    match_dynamic_route(request_path)
  end
end
