# frozen_string_literal: true

require 'prism'
require 'prism_ext'

class NodeQuery::PrismAdapter
  def is_node?(node)
    node.is_a?(Prism::Node)
  end

  def get_node_type(node)
    node.type
  end

  def get_source(node)
    node.to_source
  end

  def get_children(node)
    keys = []
    children = []
    node.deconstruct_keys([]).each do |key, value|
      next if [:node_id, :flags, :location].include?(key)

      if key.to_s.end_with?('_loc')
        new_key = key.to_s[0..-5]
        unless keys.include?(new_key)
          keys << new_key
          children << node.send(new_key)
        end
      else
        unless keys.include?(key.to_s)
          keys << key.to_s
          children << value
        end
      end
    end
    children
  end

  def get_siblings(node)
    child_nodes = get_children(node.parent_node)
    if child_nodes.is_a?(Array) && child_nodes.size == 1 && child_nodes.first.is_a?(Array)
      index = child_nodes.first.index(node)
      return child_nodes.first[index + 1...]
    end

    index = child_nodes.index(node)
    child_nodes[index + 1...]
  end
end
