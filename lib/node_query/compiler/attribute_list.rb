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
    # @param base_node [Node] the base node for evaluated value
    # @return [Boolean]
    def match?(node, base_node)
      @attribute.match?(node, base_node) && (!@rest || @rest.match?(node, base_node))
    end

    def to_s
      "[#{@attribute}]#{@rest}"
    end
  end
end
