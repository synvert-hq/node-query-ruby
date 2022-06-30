# frozen_string_literal: true

require 'active_support/core_ext/array'

require_relative "node_query/version"
require_relative "./node_query_lexer.rex"
require_relative "./node_query_parser.racc"

class NodeQuery
  autoload :Adapter, "node_query/adapter"
  autoload :ParserAdapter, "node_query/parser_adapter"
  autoload :Compiler, "node_query/compiler"
  autoload :Helper, "node_query/helper"

  # Configure NodeQuery
  # @param [Hash] options options to configure
  # @option options [NodeQuery::Adapter] :adapter the adpater
  def self.configure(options)
    @adapter = options.adapter
  end

  # Get the adapter
  # @return [NodeQuery::Adapter] current adapter, by default is {NodeQuery::ParserAdapter}
  def self.adapter
    @adapter ||= ParserAdapter.new
  end

  # Initialize a NodeQuery.
  # @param nql [String] node query language
  def initialize(nql)
    @expression = NodeQueryParser.new.parse(nql)
  end

  # Parse ast node.
  # @param node [Node] ast node
  # @return [Array<Node>] matching child nodes
  def parse(node)
    @expression.query_nodes(node)
  end
end
