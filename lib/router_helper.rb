# router_helper.rb
module RouterHelper
  def resolve_paths(path, current_file_dir)
    absolute_path = if File.directory?(path)
                      path
                    else
                      File.expand_path(path, current_file_dir)
                    end

    relative_base_path = path.sub(/\*.*$/, '') + Pathname::SEPARATOR_LIST
    absolute_base_path = File.realpath(File.expand_path(relative_base_path, current_file_dir))

    [absolute_path, absolute_base_path]
  end

  def expand_directory_glob_patterns(paths, current_file_dir)
    patterns = {}

    paths.each do |path|
      absolute_path, absolute_base_path = resolve_paths(path, current_file_dir)

      raise StandardError, 'Directory router cannot serve file' if File.file?(absolute_base_path)

      expanded_patterns = Dir[File.directory?(absolute_path) ? File.join(absolute_path, '**', '*') : absolute_path]

      patterns[absolute_base_path] = expanded_patterns
    end

    patterns
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
end
