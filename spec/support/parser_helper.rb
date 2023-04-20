# frozen_string_literal: true

require "parser"
require "parser/current"
require "parser_node_ext"
require "syntax_tree_ext"

module ParserHelper
  def parse(code)
    Parser::CurrentRuby.parse(code)
  end

  def syntax_tree_parse(code)
    SyntaxTree::Parser.new(code).parse.statements.body.first
  end
end
