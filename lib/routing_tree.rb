# frozen_string_literal: true

module Httrb
  #
  # Abstract Base Class for a Routing Tree
  #
  class RoutingTree
    def clear
      raise NotImplementedError, "#{self.class} must implement `clear`"
    end

    def insert(path, method, data)
      raise NotImplementedError, "#{self.class} must implement `insert`"
    end

    def find(path, method)
      raise NotImplementedError, "#{self.class} must implement `find`"
    end
  end
end
