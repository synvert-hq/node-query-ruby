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
    # @param options [Hash] if query the current node
    # @option options [boolean] :including_self if query the current node, default is ture
    # @option options [boolean] :stop_at_first_match if stop at first match, default is false
    # @option options [boolean] :recursive if recursively query child nodes, default is true
    # @return [Array<Node>] matching nodes.
    def query_nodes(node, options = {})
      matching_nodes = @selector.query_nodes(node, options)
      return matching_nodes if @rest.nil?

      matching_nodes.flat_map do |matching_node|
        @rest.query_nodes(matching_node, options)
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
