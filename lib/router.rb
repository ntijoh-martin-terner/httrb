require_relative "response"
require 'pathname'

class Router 
    def initialize()
      @routes = {}
    end

    def add_file_route(path_alias, path)
      current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

      absolute_base_path = File.realpath(File.expand_path(path, current_file_dir))

      if File.directory?(absolute_base_path)
        raise Exception.new "File router cannot serve directory"
      end

      @routes[path_alias] = {:type => :file, :file_path => absolute_base_path, :action => nil}
    end

    def add_directory_route(path_alias, paths) #route that will serve content, if not recursive then it will serve either the filename provided only or file.extension with that route exactly
      #check if it exists
      patterns = {}
      
      current_file_dir = File.expand_path(File.dirname(caller_locations.first.path))

      paths.each do | path | 
  
        # Join the current file directory with the relative path
        absolute_path = File.expand_path(path, current_file_dir)
  
        # relative_base_path = Pathname.new(path).dirname.to_s + Pathname::SEPARATOR_LIST
        relative_base_path = path.sub(/\*.*$/, '') + Pathname::SEPARATOR_LIST # remove glob patterns from path
  
        absolute_base_path = File.realpath(File.expand_path(relative_base_path, current_file_dir))

        if File.file?(absolute_base_path)
          raise Exception.new "Directory router cannot serve file"
        end
  
        expanded_patterns = Dir[File.directory?(absolute_path) ? File.join(absolute_path, '**', '*') : absolute_path]
  
        patterns[absolute_base_path] = expanded_patterns
      end
      if @routes.key? path_alias
        # @routes[path_alias]
        raise Exception.new "Route alias already exists"
        return
      end       


      @routes[path_alias] = {:type => :directory, :patterns => patterns, :action => nil}
    end

    def add_route(path_alias, &action)
      #check if it exists
      @routes[path_alias] = {:type => :route, :action => action}
    end

    def match_route(request)
      # Extract the path from the request
      request_path = request.resource 

      if @routes.key?(request_path)
        route = @routes[request_path]
        if route[:type] == :route
          # Call the action for this route and return its result
          return @routes[request_path][:action].call
        elsif route[:type] == :file
          return Response.from_file(route[:file_path])
        end
      end

      @routes.each do |route_path, route|
        if route[:type] != :directory 
          next
        end

        patterns = route[:patterns]
        # base_path = route[:basePath]

        patterns.each do | base_path, expanded_paths |
          relative_request_path = request_path.split(route_path)[1]
  
          if relative_request_path.nil?
            next
          end
  
          expanded_request_path = File.join(base_path, relative_request_path)
  
          if !expanded_paths.include? expanded_request_path
            next
          end
  
          return Response.from_file(expanded_request_path)          
        end

      end

      Response.not_found
    end
end