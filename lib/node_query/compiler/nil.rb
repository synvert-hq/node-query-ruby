# frozen_string_literal: true

module NodeQuery::Compiler
  # Nil represents a ruby nil value.
  class Nil
    include Comparable

    # Initialize a Nil.
    # @param value [nil] the nil value
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
      'nil'
    end
  end
end
