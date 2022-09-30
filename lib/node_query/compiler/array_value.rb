# frozen_string_literal: true

module NodeQuery::Compiler
  # ArrayValue represents a ruby array value.
  class ArrayValue
    include Comparable

    # Initialize an Array.
    # @param value the first value of the array
    # @param rest the rest value of the array
    def initialize(value: nil, rest: nil)
      @value = value
      @rest = rest
    end

    # Get the expected value.
    # @return [Array]
    def expected_value(base_node)
      expected = []
      expected.push(@value) if @value
      expected += @rest.expected_value(base_node) if @rest
      expected
    end

    # Get valid operators.
    # @return [Array] valid operators
    def valid_operators
      ARRAY_VALID_OPERATORS
    end

    def to_s
      [@value, @rest].compact.join(' ')
    end
  end
end
