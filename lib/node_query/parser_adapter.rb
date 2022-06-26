# frozen_string_literal: true

class NodeQuery::ParserAdapter
  def get_node_type(node)
    node.type
  end

  def get_source(node)
    node.loc.expression.source
  end

  def get_children(node)
    node.is_a?(Parser::AST::Node) ? node.children : []
  end

  def get_siblings(node)
    index = node.parent.children.index(node)
    node.parent.children[index + 1..]
  end
end