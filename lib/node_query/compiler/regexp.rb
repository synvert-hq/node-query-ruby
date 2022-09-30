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
    # @param _base_node [Node] the base node for evaluated value
    # @param operator [String] the operator
    # @return [Boolean] true if the regexp value matches the node value, otherwise, false.
    def match?(node, _base_node, operator = '=~')
      match =
        if NodeQuery.adapter.is_node?(node)
          @value.match(NodeQuery.adapter.get_source(node))
        else
          @value.match(node.to_s)
        end
      operator == '=~' ? match : !match
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
