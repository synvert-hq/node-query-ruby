# frozen_string_literal: true

module NodeQuery::Compiler
  # AttributeList contains one or more {NodeQuery::Compiler::Attribute}.
  class AttributeList
    # Initialize an AttributeList.
    # @param attribute [NodeQuery::Compiler::Attribute] the attribute
    # @param rest [NodeQuery::Compiler::AttributeList] the rest attribute list
    def initialize(attribute:, rest: nil)
      @attribute = attribute
      @rest = rest
    end

    # Check if the node matches the attribute list.
    # @param node [Node] the node
    # @return [Boolean]
    def match?(node)
      @attribute.match?(node) && (!@rest || @rest.match?(node))
    end

    def to_s
      "[#{@attribute}]#{@rest}"
    end
  end
end
