require_relative "response"
require 'pathname'

class Router 
    def initialize()
      @routes = {}
    end

    def add_content_route(path_alias, path) #route that will serve content, if not recursive then it will serve either the filename provided only or file.extension with that route exactly
      #check if it exists
      current_file_dir = File.expand_path(File.dirname(__FILE__))

      # Join the current file directory with the relative path
      absolute_path = File.expand_path(path, current_file_dir)

      relative_base_path = Pathname.new(path).dirname.to_s + Pathname::SEPARATOR_LIST

      absolute_base_path = File.realpath(File.expand_path(relative_base_path, current_file_dir))

      expanded_patterns = Dir[File.directory?(absolute_path) ? File.join(absolute_path, '**', '*') : absolute_path]

      # expanded_patterns.map { |path| File.expand_path(path, absolute_base_path) }

      @routes[path_alias] = {:content => true, :basePath => absolute_base_path, :expanded_paths => expanded_patterns, :action => nil}
    end

    def add_route(path_alias, &action)
      #check if it exists
      @routes[path_alias] = {:content => false, :action => action}
    end

    def match_route(request)
      # Extract the path from the request
      request_path = request.resource 

      if @routes.key?(request_path)
        route = @routes[request_path]
        if route[:content] == false
          # Call the action for this route and return its result
          return Response.new(200, @routes[request_path][:action].call, "text/html")
        else
          return Response.fromFile(route[:basePath])
        end
      end

      @routes.each do |route_path, route|
        if route[:content] == false 
          next
        end

        base_path = route[:basePath]

        expanded_request_path = File.join(base_path, request_path)

        route[:expanded_paths].each do | expanded_path |
          if expanded_request_path != expanded_path
            next
          end

          return Response.fromFile(expanded_request_path)
        end
      end

      return Response.new(404,"404 Not Found","text/html")
    end
end