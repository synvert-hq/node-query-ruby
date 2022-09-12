# frozen_string_literal: true

module NodeQuery::Compiler
  # String represents a ruby string value.
  class String
    include Comparable

    attr_accessor :base_node

    # Initialize a String.
    # @param value [String] the string value
    def initialize(value:)
      @value = value
    end

    def expected_value
      NodeQuery::Helper.evaluate_node_value(base_node, @value)
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
