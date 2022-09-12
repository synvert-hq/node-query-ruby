# frozen_string_literal: true

module NodeQuery::Compiler
  # Regexp represents a ruby regexp value.
  class Regexp
    include Comparable

    # Initialize a Regexp.
    # @param value [Regexp] the regexp value
    def initialize(value:)
      @value = value
    end

    # Check if the regexp value matches the node value.
    # @param node [Node] the node
    # @return [Boolean] true if the regexp value matches the node value.
    def is_equal?(node)
      if NodeQuery.adapter.is_node?(node)
        @value.match(NodeQuery.adapter.get_source(node))
      else
        @value.match(node.to_s)
      end
    end

    # Get valid operators.
    # @return [Array] valid operators
    def valid_operators
      REGEXP_VALID_OPERATORS
    end

    def to_s
      @value.to_s
    end
  end
end
