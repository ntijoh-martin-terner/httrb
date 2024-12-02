# frozen_string_literal: true

require_relative 'routing_tree'

# (root)
#  ├── user/
#  │    ├── profile
#  │    ├── settings
#  │    └── :id
#  └── product/
#       └── :productId

module Httrb
  #
  # Radix Tree for HTTP Routing
  #
  class RadixTree < RoutingTree
    def initialize
      @root = { segments: {}, routes: {} }
      super
    end

    def clear
      @root = { segments: {}, routes: {} }
    end

    def insert(path, method, route)
      formatted_path = path.gsub(%r{^/|/$}, '')
      segments = formatted_path.split('/')

      current_node = @root

      segments.each do |segment|
        current_node = current_node[:segments]

        current_node[segment] = { segments: {}, routes: {} } unless current_node.key?(segment)

        current_node = current_node[segment]
      end

      current_node[:routes][method] = route
    end

    def find_next_node(segments, segment_index, method, current_node, variables = [])
      return nil if segment_index > segments.length - 1

      segment = segments[segment_index]

      if !current_node.key?(segment) || segment[0] == ':'
        current_node.each_key do |tree_segment|
          next unless tree_segment[0] == ':' # is a variable

          variables.append(segment)

          current_node = current_node[tree_segment]

          if segment_index + 1 > segments.length - 1
            return { route: current_node[:routes][method], variables: variables }
          end

          possible_route = find_next_node(segments, segment_index + 1, method, current_node[:segments],
                                          variables)
          return possible_route unless possible_route.nil?
        end

        return nil
      end

      current_node = current_node[segment]

      return { route: current_node[:routes][method], variables: variables } if segment_index == segments.length - 1

      find_next_node(segments, segment_index + 1, method, current_node[:segments], variables)
    end

    def find(path, method)
      formatted_path = path.gsub(%r{^/|/$}, '')
      segments = formatted_path.split('/')

      find_next_node(segments, 0, method, @root[:segments])
    end
  end
end

# tree = Httrb::RadixTree.new

# tree.insert('/foo/:variable/hello/:second-variable/:lastvariable', 'GET', { data: 'hello' })
# tree.insert('/foo/:variable/hello/:second-variable/hahah', 'GET', { data: 'duhwdhiuwd' })
# tree.insert('hello/:this/that', 'GET', { data: 'hello' })
# tree.insert('hello/:this/:second_variable/that', 'POST', { data: 'posthello' })
# tree.insert('content/test.txt', 'GET', { data: 'test' })
# # tree.insert('/foo/variable/hello/second/last/', 'GET', {data: 'abc'})
# p tree.find('hello/that/that', 'GET')
# p tree.find('hello/:tja/second/that', 'POST')
# p tree.find('content/test.txt', 'GET')
# p tree.find('foo/variable/hello/second/hahah', 'GET')
# p tree.find('/foo/variable/hello/second/last', 'GET')


# tree.insert('/content/frog.gif', 'GET', {test: 'hello'})

# p tree.find('/content/frog.gif', 'GET')

# p tree
