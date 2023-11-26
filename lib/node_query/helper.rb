# frozen_string_literal: true

class NodeQuery::Helper
  class << self
    # Get target node by the keys.
    # @param node [Node] ast node
    # @param keys [String|Array] keys of child node.
    # @param adapter [NodeQuery::Adapter]
    # @return [Node|] the target node.
    def get_target_node(node, keys, adapter)
      return unless node

      first_key, rest_keys = keys.to_s.split('.', 2)
      if node.is_a?(Array) && first_key === "*"
        return node.map { |child_node| get_target_node(child_node, rest_keys, adapter) }
      end

      if node.is_a?(Array) && first_key =~ /\d+/
        child_node = node[first_key.to_i]
      elsif node.respond_to?(first_key)
        child_node = node.send(first_key)
      elsif first_key == "node_type"
        child_node = adapter.get_node_type(node)
      end

      return child_node unless rest_keys

      return get_target_node(child_node, rest_keys, adapter)
    end

    # Recursively handle child nodes.
    # @param node [Node] ast node
    # @param adapter [NodeQuery::Adapter] adapter
    # @yield [child] Gives a child node.
    # @yieldparam child [Node] child node
    def handle_recursive_child(node, adapter, &block)
      adapter.get_children(node).each do |child|
        handle_child(child, adapter, &block)
      end
    end

    # Evaluate node value.
    # @example
    #     source code of the node is @id = id
    #     evaluated_node_value(node, "@{{value}}") # => @id
    # @param node [Node] ast node
    # @param str [String] string to be evaluated
    # @param adapter [NodeQuery::Adapter] adapter
    # @return [String] evaluated string
    def evaluate_node_value(node, str, adapter)
      str.scan(/{{(.+?)}}/).each do |match_data|
        target_node = NodeQuery::Helper.get_target_node(node, match_data.first, adapter)
        str = str.sub("{{#{match_data.first}}}", to_string(target_node, adapter))
      end
      str
    end

    def to_string(node, adapter)
      if adapter.is_node?(node)
        return adapter.get_source(node)
      end

      node.to_s
    end

    private

    def handle_child(node, adapter, &block)
      if adapter.is_node?(node)
        block.call(node)
        handle_recursive_child(node, adapter, &block)
      elsif node.is_a?(Array)
        node.each do |child_node|
          handle_child(child_node, adapter, &block) unless child_node.nil?
        end
      end
    end
  end
end
