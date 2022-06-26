# frozen_string_literal: true

require "parser/current"

module ParserHelper
  def parse(code)
    Parser::CurrentRuby.parse(code)
  end
end
