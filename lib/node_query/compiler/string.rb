# frozen_string_literal: true

module NodeQuery::Compiler
  # String represents a ruby string value.
  class String
    include Comparable

    # Initialize a String.
    # @param value [String] the string value
    def initialize(value:)
      @value = value
    end

    # Get the expected value.
    # @example
    #     if the source code of the node is @id = id,
    #     and the @value is "@{{right_vaue}}",
    #     then it returns "@id".
    # @param base_node [Node] the base node for evaluated value
    # @return [String] the expected string, if it contains evaluated value, evaluate the node value.
    def expected_value(base_node)
      NodeQuery::Helper.evaluate_node_value(base_node, @value)
    end

    # Check if the actual value equals the node value.
    # @param node [Node] the node
    # @param base_node [Node] the base node for evaluated value
    # @return [Boolean] true if the actual value equals the node value.
    def is_equal?(actual, expected)
      NodeQuery::Helper.to_string(actual) == expected
    end

    # Get valid operators.
    # @return [Array] valid operators
    def valid_operators
      STRING_VALID_OPERATORS
    end

    def to_s
      "\"#{@value}\""
    end
  end
end
