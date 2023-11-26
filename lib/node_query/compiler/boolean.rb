# frozen_string_literal: true

module NodeQuery::Compiler
  # Boolean represents a ruby boolean value.
  class Boolean
    include Comparable

    # Initialize a Boolean.
    # @param value [Boolean] the boolean value
    # @param adapter [NodeQuery::Adapter]
    def initialize(value:, adapter:)
      @value = value
      @adapter = adapter
    end

    # Get valid operators.
    # @return [Array] valid operators
    def valid_operators
      SIMPLE_VALID_OPERATORS
    end

    def to_s
      @value.to_s
    end
  end
end
