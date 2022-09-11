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
  autoload :NodeRules, "node_query/node_rules"

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
  # @param nqlOrRules [String | Hash] node query language or node rules
  def initialize(nqlOrRules)
    if nqlOrRules.is_a?(String)
      @expression = NodeQueryParser.new.parse(nqlOrRules)
    else
      @rules = NodeRules.new(nqlOrRules)
    end
  end

  # Query matching nodes.
  # @param node [Node] ast node
  # @param including_self [boolean] if check the node itself
  # @return [Array<Node>] matching child nodes
  def query_nodes(node, including_self = true)
    if @expression
      @expression.query_nodes(node, including_self)
    elsif @rules
      @rules.query_nodes(node, including_self)
    else
      []
    end
  end

  # Check if the node matches the nql or rules.
  # @param node [Node] the node
  # @return [Boolean]
  def match_node?(node)
    if @expression
      @expression.match_node?(node)
    elsif @rules
      @rules.match_node?(node)
    else
      false
    end
  end
end
