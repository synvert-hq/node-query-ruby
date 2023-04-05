# frozen_string_literal: true

module NodeQuery::Compiler
  # BasicSelector used to match nodes, it combines by node type and/or attribute list.
  class BasicSelector
    # Initialize a BasicSelector.
    # @param node_type [String] the node type
    # @param attribute_list [NodeQuery::Compiler::AttributeList] the attribute list
    def initialize(node_type:, attribute_list: nil)
      @node_type = node_type
      @attribute_list = attribute_list
    end

    # Check if node matches the selector.
    # @param node [Node] the node
    # @param base_node [Node] the base node for evaluated value
    # @return [Boolean]
    def match?(node, base_node, _operator = '==')
      return false unless node

      @node_type.to_sym == NodeQuery.adapter.get_node_type(node) && (!@attribute_list || @attribute_list.match?(
        node,
        base_node
      ))
    end

    def to_s
      result = [".#{@node_type}"]
      result << @attribute_list.to_s if @attribute_list
      result.join('')
    end
  end
end
