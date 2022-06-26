# frozen_string_literal: true

class NodeQuery::Helper
  # Get target node by the keys.
  # @param node [Node] ast node
  # @param keys [String] keys of child node.
  # @return [Node|] the target node.
  def self.get_target_node(node, keys)
    return unless node

    first_key, rest_keys = keys.to_s.split('.', 2)
    if (node.is_a?(Array) && first_key === "*")
      return node.map { |child_node| get_target_node(child_node, rest_keys) }
    end

    if node.respond_to?(first_key)
      child_node = node.send(first_key)
    end

    return child_node unless rest_keys

    return get_target_node(child_node, rest_keys)
  end

  # Recursively handle child nodes.
  # @param node [Node] ast node
  # @yield [child] Gives a child node.
  # @yieldparam child [Parser::AST::Node] child node
  def self.handle_recursive_child(node, &block)
    NodeQuery.get_adapter.get_children(node).each do |child|
      block.call(child)
      handle_recursive_child(child, &block)
    end
  end
end