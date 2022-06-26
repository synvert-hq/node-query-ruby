# frozen_string_literal: true

module NodeQuery::Compiler
  # EvaluatedValue represents a ruby dynamic attribute.
  # e.g. code is <code>{ a: a }</code>, query is <code>'.hash > .pair[key={{value}}]'</code>,
  # <code>{{value}}</code> is the dynamic attribute.
  class EvaluatedValue
    include Comparable

    attr_accessor :base_node

    # Initialize an EvaluatedValue.
    # @param value [String] the dynamic attribute value
    def initialize(value:)
      @value = value
    end

    # Get the actual value of a node.
    # @param node [Node] the node
    # @return [String] if node is a {Node}, return the node source code, otherwise return the node itself.
    def actual_value(node)
      if node.is_a?(::Parser::AST::Node)
        NodeQuery.get_adapter.get_source(node)
      else
        node
      end
    end

    # Get the expected value.
    # @return [String] Query the node by @value from base_node, if the node is a {Node}, return the node source code, otherwise return the node itself.
    def expected_value
      node = NodeQuery::Helper.get_target_node(base_node, @value)
      if node.is_a?(::Parser::AST::Node)
        NodeQuery.get_adapter.get_source(node)
      else
        node
      end
    end

    # Get valid operators.
    # @return [Array] valid operators
    def valid_operators
      SIMPLE_VALID_OPERATORS
    end

    def to_s
      "{{#{@value}}}"
    end
  end
end
