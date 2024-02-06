# frozen_string_literal: true

require 'prism'

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
    # TODO: implement get_siblings
  end
end
