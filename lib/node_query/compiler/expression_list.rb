# frozen_string_literal: true

module NodeQuery::Compiler
  # ExpressionList contains one or more {NodeQuery::Compiler::Expression}.
  class ExpressionList
    # Initialize an ExpressionList.
    # @param expression [NodeQuery::Compiler::Expression] the expression
    # @param rest [NodeQuery::Compiler::ExpressionList] the rest expression list
    def initialize(expression:, rest: nil)
      @expression = expression
      @rest = rest
    end

    # Query nodes by the current and the rest expression.
    # @param node [Node] node to match
    # @params including_self [boolean] if query the current node.
    # @return [Array<Node>] matching nodes.
    def query_nodes(node, including_self = true)
      matching_nodes = @expression.query_nodes(node, including_self)
      return matching_nodes if @rest.nil?

      matching_nodes + @rest.query_nodes(node, including_self)
    end

    # Check if the node matches the expression list.
    # @param node [Node] the node
    # @return [Boolean]
    def match_node?(node)
      !query_nodes(node).empty?
    end

    def to_s
      [@expression, @rest].compact.join(', ')
    end
  end
end
