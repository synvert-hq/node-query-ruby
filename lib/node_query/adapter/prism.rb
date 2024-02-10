# frozen_string_literal: true

require 'prism'
require 'prism_ext'

class NodeQuery::PrismAdapter
  def is_node?(node)
    node.is_a?(Prism::Node)
  end

  def get_node_type(node)
    node.class.name.split('::').last.to_sym
  end

  def get_source(node)
    node.slice
  end

  def get_children(node)
    node.child_nodes
  end

  def get_siblings(node)
    child_nodes = node.parent_node.child_nodes
    if child_nodes.is_a?(Array) && child_nodes.size == 1 && child_nodes.first.is_a?(Array)
      index = child_nodes.first.index(node)
      return child_nodes.first[index + 1...]
    end

    index = child_nodes.index(node)
    child_nodes[index + 1...]
  end
end
