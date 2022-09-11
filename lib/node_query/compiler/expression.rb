# frozen_string_literal: true

module NodeQuery::Compiler
  # Expression represents a node query expression.
  class Expression
    # Initialize a Expression.
    # @param selector [NodeQuery::Compiler::Selector] the selector
    # @param rest [NodeQuery::Compiler::Expression] the rest expression
    def initialize(selector: nil, rest: nil)
      @selector = selector
      @rest = rest
    end

    # Query nodes by the selector and the rest expression.
    # @param node [Node] node to match
    # @params including_self [boolean] if query the current node.
    # @return [Array<Node>] matching nodes.
    def query_nodes(node, including_self = true)
      matching_nodes = @selector.query_nodes(node, including_self)
      return matching_nodes if @rest.nil?

      matching_nodes.flat_map do |matching_node|
        @rest.query_nodes(matching_node, including_self)
      end
    end

    def to_s
      result = []
      result << @selector.to_s if @selector
      result << @rest.to_s if @rest
      result.join(' ')
    end
  end
end
