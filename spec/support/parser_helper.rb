# frozen_string_literal: true

require "parser"
require "parser/current"
require "parser_node_ext"

module ParserHelper
  def parse(code)
    Parser::CurrentRuby.parse(code)
  end
end
