# frozen_string_literal: true

module NodeQuery::Compiler
  # Identifier represents a ruby identifier value.
  # e.g. code is `class Synvert; end`, `Synvert` is an identifier.
  class Identifier
    include Comparable

    # Initialize an Identifier.
    # @param value [String] the identifier value
    # @param adapter [NodeQuery::Adapter]
    def initialize(value:, adapter:)
      @value = value
      @adapter = adapter
    end

    # Get the actual value.
    # @param node [Node] the node
    # @return [String|Array]
    # If the node is a {Node}, return the node source code,
    # if the node is an Array, return the array of each element's actual value,
    # otherwise, return the String value.
    def actual_value(node)
      if @adapter.is_node?(node)
        @adapter.get_source(node)
      elsif node.is_a?(::Array)
        node.map { |n| actual_value(n) }
      else
        node.to_s
      end
    end

    # Get valid operators.
    # @return [Array] valid operators
    def valid_operators
      STRING_VALID_OPERATORS
    end

    def to_s
      @value
    end
  end
end
