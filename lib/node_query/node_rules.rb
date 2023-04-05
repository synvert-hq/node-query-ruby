# frozen_string_literal: true

class NodeQuery::NodeRules
  KEYWORDS = %i[not_includes includes not in not_in gt gte lt lte]

  # Initialize a NodeRules.
  # @param rules [Hash] the nod rules
  def initialize(rules)
    @rules = rules
  end

  # Query nodes by the rules.
  # @param node [Node] node to query
  # @param options [Hash] if query the current node
  # @option options [boolean] :including_self if query the current node, default is ture
  # @option options [boolean] :stop_at_first_match if stop at first match, default is false
  # @option options [boolean] :recursive if recursively query child nodes, default is true
  # @return [Array<Node>] matching nodes.
  def query_nodes(node, options = {})
    options = { including_self: true, stop_at_first_match: false, recursive: true }.merge(options)
    if options[:including_self] && !options[:recursive]
      return match_node?(node) ? [node] : []
    end

    matching_nodes = []
    if options[:including_self] && match_node?(node)
      matching_nodes.push(node)
      return matching_nodes if options[:stop_at_first_match]
    end
    if options[:recursive]
      NodeQuery::Helper.handle_recursive_child(node) do |child_node|
        if match_node?(child_node)
          matching_nodes.push(child_node)
          break if options[:stop_at_first_match]
        end
      end
    else
      NodeQuery.adapter.get_children(node).each do |child_node|
        if match_node?(child_node)
          matching_nodes.push(child_node)
          break if options[:stop_at_first_match]
        end
      end
    end
    matching_nodes
  end

  # Check if the node matches the rules.
  # @param node [Node] the node
  # @return [Boolean]
  def match_node?(node)
    flat_hash(@rules).keys.all? do |multi_keys|
      last_key = multi_keys.last
      actual =
        KEYWORDS.include?(last_key) ?
               NodeQuery::Helper.get_target_node(node, multi_keys[0...-1].join('.')) :
               NodeQuery::Helper.get_target_node(node, multi_keys.join('.'))
      expected = expected_value(@rules, multi_keys)
      expected = NodeQuery::Helper.evaluate_node_value(node, expected) if expected.is_a?(String)
      case last_key
      when :includes
        actual.any? { |actual_value| match_value?(actual_value, expected) }
      when :not_includes
        actual.all? { |actual_value| !match_value?(actual_value, expected) }
      when :not
        !match_value?(actual, expected)
      when :in
        expected.any? { |expected_value| match_value?(actual, expected_value) }
      when :not_in
        expected.all? { |expected_value| !match_value?(actual, expected_value) }
      when :gt
        actual > expected
      when :gte
        actual >= expected
      when :lt
        actual < expected
      when :lte
        actual <= expected
      else
        match_value?(actual, expected)
      end
    end
  end

  private

  # Compare actual value with expected value.
  #
  # @param actual [Object] actual value.
  # @param expected [Object] expected value.
  # @return [Boolean]
  # @raise [NodeQuery::MethodNotSupported] if expected class is not supported.
  def match_value?(actual, expected)
    return true if actual == expected

    case expected
    when Symbol
      if actual.is_a?(Parser::AST::Node)
        actual_source = NodeQuery.adapter.get_source(actual)
        actual_source == ":#{expected}" || actual_source == expected.to_s
      else
        actual.to_sym == expected
      end
    when String
      if actual.is_a?(Parser::AST::Node)
        actual_source = NodeQuery.adapter.get_source(actual)
        actual_source == expected || actual_source == unwrap_quote(expected) ||
          unwrap_quote(actual_source) == expected || unwrap_quote(actual_source) == unwrap_quote(expected)
      else
        actual.to_s == expected || wrap_quote(actual.to_s) == expected
      end
    when Regexp
      if actual.is_a?(Parser::AST::Node)
        actual.to_source =~ Regexp.new(expected.to_s, Regexp::MULTILINE)
      else
        actual.to_s =~ Regexp.new(expected.to_s, Regexp::MULTILINE)
      end
    when Array
      return false unless expected.length == actual.length

      actual.zip(expected).all? { |a, e| match_value?(a, e) }
    when NilClass
      if actual.is_a?(Parser::AST::Node)
        :nil == actual.type
      else
        actual.nil?
      end
    when Numeric
      if actual.is_a?(Parser::AST::Node)
        actual.children[0] == expected
      else
        actual == expected
      end
    when TrueClass
      :true == actual&.type
    when FalseClass
      :false == actual&.type
    when Parser::AST::Node
      actual == expected
    else
      raise NodeQuery::MethodNotSupported, "#{expected} is not supported"
    end
  end

  # Convert a hash to flat one.
  #
  # @example
  #   flat_hash(node_type: 'block', caller: { node_type: 'send', receiver: 'RSpec' })
  #     # {[:node_type] => 'block', [:caller, :node_type] => 'send', [:caller, :receiver] => 'RSpec'}
  # @param h [Hash] original hash.
  # @return flatten hash.
  def flat_hash(h, k = [])
    new_hash = {}
    h.each_pair do |key, val|
      if val.is_a?(Hash)
        new_hash.merge!(flat_hash(val, k + [key]))
      else
        new_hash[k + [key]] = val
      end
    end
    new_hash
  end

  # Get expected value from rules.
  #
  # @param rules [Hash]
  # @param multi_keys [Array<Symbol>]
  # @return [Object] expected value.
  def expected_value(rules, multi_keys)
    multi_keys.inject(rules) { |o, key| o[key] }
  end

  # Wrap the string with single or double quote.
  # @param string [String]
  # @return [String]
  def wrap_quote(string)
    if string.include?("'")
      "\"#{string}\""
    else
      "'#{string}'"
    end
  end

  # Unwrap the quote from the string.
  # @param string [String]
  # @return [String]
  def unwrap_quote(string)
    if (string[0] == '"' && string[-1] == '"') || (string[0] == "'" && string[-1] == "'")
      string[1...-1]
    else
      string
    end
  end
end
