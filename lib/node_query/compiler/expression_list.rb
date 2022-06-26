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
    # @return [Array<Node>] matching nodes.
    def query_nodes(node)
      matching_nodes = @expression.query_nodes(node)
      return matching_nodes if @rest.nil?

      matching_nodes + @rest.query_nodes(node)
    end

    def to_s
      [@expression, @rest].compact.join(', ')
    end
  end
end
