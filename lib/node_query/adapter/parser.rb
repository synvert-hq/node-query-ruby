# frozen_string_literal: true

class NodeQuery::ParserAdapter
  def is_node?(node)
    node.is_a?(Parser::AST::Node)
  end

  def get_node_type(node)
    node.type
  end

  def get_source(node)
    node.loc.expression.source
  end

  def get_children(node)
    node.children
  end

  def get_siblings(node)
    index = node.parent.children.index(node)
    node.parent.children[index + 1..]
  end
end
