# frozen_string_literal: true

require 'parser/current'
require 'syntax_tree'

module ParserHelper
  def parse(code)
    Parser::CurrentRuby.parse(code)
  end

  def syntax_tree_parse(code)
    SyntaxTree::Parser.new(code).parse.statements.body.first
  end
end
