# frozen_string_literal: true

class NodeQuery::Helper
  class << self
    # Get target node by the keys.
    # @param node [Node] ast node
    # @param keys [String|Array] keys of child node.
    # @return [Node|] the target node.
    def get_target_node(node, keys)
      return unless node

      first_key, rest_keys = keys.to_s.split('.', 2)
      if node.is_a?(Array) && first_key === "*"
        return node.map { |child_node| get_target_node(child_node, rest_keys) }
      end

      if node.is_a?(Array) && first_key =~ /\d+/
        child_node = node[first_key.to_i]
      elsif node.respond_to?(first_key)
        child_node = node.send(first_key)
      elsif first_key == "node_type"
        child_node = NodeQuery.adapter.get_node_type(node)
      end

      return child_node unless rest_keys

      return get_target_node(child_node, rest_keys)
    end

    # Recursively handle child nodes.
    # @param node [Node] ast node
    # @yield [child] Gives a child node.
    # @yieldparam child [Parser::AST::Node] child node
    def handle_recursive_child(node, &block)
      NodeQuery.adapter.get_children(node).each do |child|
        if NodeQuery.adapter.is_node?(child)
          block.call(child)
          handle_recursive_child(child, &block)
        end
      end
    end

    # Evaluate node value.
    # @example
    #     source code of the node is @id = id
    #     evaluated_node_value(node, "@{{value}}") # => @id
    # @param node [Node] ast node
    # @param str [String] string to be evaluated
    # @return [String] evaluated string
    def evaluate_node_value(node, str)
      str.scan(/{{(.+?)}}/).each do |match_data|
        target_node = NodeQuery::Helper.get_target_node(node, match_data.first)
        str = str.sub("{{#{match_data.first}}}", to_string(target_node))
      end
      str
    end

    def to_string(node)
      if NodeQuery.adapter.is_node?(node)
        return NodeQuery.adapter.get_source(node)
      end

      node.to_s
    end
  end
end
