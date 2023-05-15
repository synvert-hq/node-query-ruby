# frozen_string_literal: true

require 'syntax_tree'
require 'syntax_tree_ext'

class NodeQuery::SyntaxTreeAdapter
  def is_node?(node)
    node.is_a?(SyntaxTree::Node)
  end

  def get_node_type(node)
    node.class.name.split('::').last.to_sym
  end

  def get_source(node)
    node.source
  end

  def get_children(node)
    node.child_nodes
  end

  def get_siblings(node)
    node.siblings
  end
end
