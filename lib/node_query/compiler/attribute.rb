# frozen_string_literal: true

module NodeQuery::Compiler
  # Attribute is a pair of key, value and operator,
  class Attribute
    # Initialize a Attribute.
    # @param key [String] the key
    # @param value the value can be any class implement {NodeQuery::Compiler::Comparable}
    # @param operator [String] the operator
    def initialize(key:, value:, operator: '==')
      @key = key
      @value = value
      @operator = operator
    end

    # Check if the node matches the attribute.
    # @param node [Node] the node
    # @param base_node [Node] the bae node for evaluated value
    # @return [Boolean]
    def match?(node, base_node)
      node && @value.match?(NodeQuery::Helper.get_target_node(node, @key), base_node, @operator)
    end

    def to_s
      case @operator
      when '^=', '$=', '*=', '!=', '=~', '!~', '>=', '>', '<=', '<'
        "#{@key}#{@operator}#{@value}"
      when 'in'
        "#{@key} in (#{@value})"
      when 'not_in'
        "#{@key} not in (#{@value})"
      when 'includes'
        "#{@key} includes #{@value}"
      when 'not_includes'
        "#{@key} not includes #{@value}"
      else
        "#{@key}=#{@value}"
      end
    end
  end
end
