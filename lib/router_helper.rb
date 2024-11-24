# frozen_string_literal: true


#
# Helper methods for routing logic.
# Provides utility functions for expanding directory paths, matching patterns, and extracting request variables.
#
module RouterHelper
  #
  # Expands directory glob patterns into a hash mapping directories to their contained files.
  #
  # This method processes a list of paths, resolves them relative to a base directory,
  # and expands any directory into the list of files it contains.
  #
  # @param [Array<String>] paths The list of paths or glob patterns to expand.
  # @param [String] current_file_dir The base directory used to resolve relative paths.
  #
  # @raise [StandardError] If any of the provided paths is a file instead of a directory.
  #
  # @return [Hash<String, Array<String>>] A hash mapping each directory to its expanded list of files.
  #
  # @example Expanding directory glob patterns
  #   example_content_path = File.expand_path('./example_content')
  #   result = expand_directory_glob_patterns(['./*'], example_content_path)
  #   # result might contain:
  #   # {
  #   #   "/path/to/example_content" => [
  #   #     "/path/to/example_content/frog.gif",
  #   #     "/path/to/example_content/stuff",
  #   #     "/path/to/example_content/test.txt"
  #   #   ]
  #   # }
  #
  def expand_directory_glob_patterns(paths, current_file_dir)
    patterns = {}

    paths.each do |path|
      absolute_path = if File.directory?(path)
                        path
                      else
                        File.expand_path(path, current_file_dir)
                      end

      raise StandardError, 'Directory router cannot serve file' if File.file?(absolute_path)

      expanded_patterns = Dir[File.directory?(absolute_path) ? File.join(absolute_path, '**', '*') : absolute_path]

      patterns[absolute_path] = expanded_patterns
    end

    patterns
  end

  #
  # Extracts variables from a request path based on a route path.
  #
  # This method matches a route path with dynamic segments (e.g., `:var`) against a request path
  # and extracts the corresponding values.
  #
  # @param [String] route_path The route path containing dynamic segments (e.g., `'/user/:id'`).
  # @param [String] request_path The actual request path to match (e.g., `'/user/123'`).
  #
  # @return [Array<String>, nil] An array of extracted variables if the paths match, otherwise `nil`.
  #
  # @example Extracting request variables
  #   get_request_variables('/:hello/:world', '/greet/everyone')
  #   # => ["greet", "everyone"]
  #
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

  #
  # Finds the matching pattern for a given request path based on defined patterns.
  #
  # This method resolves a request path to its corresponding file path
  # using a set of base paths and their expanded contents.
  #
  # @param [Hash<String, Array<String>>] patterns A hash mapping base paths to their expanded files.
  # @param [String] route_path The route path (e.g., `'/'`).
  # @param [String] request_path The request path to resolve (e.g., `'/stuff/test.html'`).
  #
  # @return [String, nil] The matching expanded file path if found, otherwise `nil`.
  #
  # @example Finding a matching pattern
  #   patterns = {
  #     "/path/to/example_content" => [
  #       "/path/to/example_content/frog.gif",
  #       "/path/to/example_content/stuff/test.html"
  #     ]
  #   }
  #
  #   get_matching_pattern(patterns, '/', '/stuff/test.html')
  #   # => "/path/to/example_content/stuff/test.html"
  #
  def get_matching_pattern(patterns, route_path, request_path)
    patterns.each do |base_path, expanded_paths|
      relative_request_path = request_path.split(route_path, 2)[1]

      next if relative_request_path.nil?

      expanded_request_path = File.join(base_path, relative_request_path)

      next unless expanded_paths.include? expanded_request_path

      return expanded_request_path
    end

    nil
  end
end
