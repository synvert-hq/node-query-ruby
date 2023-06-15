# frozen_string_literal: true

require 'syntax_tree'
require 'syntax_tree_ext'

if RUBY_VERSION.to_i < 3
  class Hash
    def except(*keys)
      self.reject { |k, _| keys.include?(k) }
    end
  end
end

class NodeQuery::SyntaxTreeAdapter
  def is_node?(node)
    node.is_a?(SyntaxTree::Node)
  end

  def get_node_type(node)
    node.class.name.split('::').last.to_sym
  end

  def get_source(node)
    node.to_source
  end

  def get_children(node)
    node.deconstruct_keys([]).except(:location, :comments).values
  end

  def get_siblings(node)
    node.siblings
  end
end
