# frozen_string_literal: true

require 'parser/current'
require 'parser_node_ext'
require 'syntax_tree_ext'
require 'prism_ext'

module ParserHelper
  def parser_parse(code)
    Parser::CurrentRuby.parse(code)
  end

  def syntax_tree_parse(code)
    SyntaxTree.parse(code).statements
  end

  def prism_parse(code)
    Prism.parse(code).value.statements
  end
end
