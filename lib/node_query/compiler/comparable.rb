# frozen_string_literal: true

module NodeQuery::Compiler
  # Compare acutal value with expected value.
  module Comparable
    SIMPLE_VALID_OPERATORS = ['==', '!=', 'includes']
    STRING_VALID_OPERATORS = ['==', '!=', '^=', '$=', '*=', 'includes']
    NUMBER_VALID_OPERATORS = ['==', '!=', '>', '>=', '<', '<=', 'includes']
    ARRAY_VALID_OPERATORS = ['==', '!=', 'in', 'not_in']
    REGEXP_VALID_OPERATORS = ['=~', '!~']

    # Check if the actual value matches the expected value.
    #
    # @param node [Node] node to calculate actual value
    # @param operator [String] operator to compare with expected value, operator can be <code>'=='</code>, <code>'!='</code>, <code>'>'</code>, <code>'>='</code>, <code>'<'</code>, <code>'<='</code>, <code>'includes'</code>, <code>'in'</code>, <code>'not_in'</code>, <code>'=~'</code>, <code>'!~'</code>
    # @return [Boolean] true if actual value matches the expected value
    # @raise [NodeQuery::Compiler::InvalidOperatorError] if operator is invalid
    def match?(node, operator)
      raise InvalidOperatorError, "invalid operator #{operator}" unless valid_operator?(operator)

      case operator
      when '!='
        if expected_value.is_a?(::Array)
          actual = actual_value(node)
          !actual.is_a?(::Array) || actual.size != expected_value.size ||
            actual.zip(expected_value).any? { |actual_node, expected_node| expected_node.match?(actual_node, '!=') }
        else
          !is_equal?(node)
        end
      when '=~'
        actual_value(node) =~ expected_value
      when '!~'
        actual_value(node) !~ expected_value
      when '^='
        actual_value(node).start_with?(expected_value)
      when '$='
        actual_value(node).end_with?(expected_value)
      when '*='
        actual_value(node).include?(expected_value)
      when '>'
        actual_value(node) > expected_value
      when '>='
        actual_value(node) >= expected_value
      when '<'
        actual_value(node) < expected_value
      when '<='
        actual_value(node) <= expected_value
      when 'in'
        if node.is_a?(Array)
          node.all? { |child| expected_value.any? { |expected| expected.match?(child, '==') } }
        else
          expected_value.any? { |expected| expected.match?(node, '==') }
        end
      when 'not_in'
        if node.is_a?(Array)
          node.all? { |child| expected_value.all? { |expected| expected.match?(child, '!=') } }
        else
          expected_value.all? { |expected| expected.match?(node, '!=') }
        end
      when 'includes'
        actual_value(node).any? { |actual| actual == expected_value }
      else
        if expected_value.is_a?(::Array)
          actual = actual_value(node)
          actual.is_a?(::Array) && actual.size == expected_value.size &&
            actual.zip(expected_value).all? { |actual_node, expected_node| expected_node.match?(actual_node, '==') }
        else
          is_equal?(node)
        end
      end
    end

    # Check if the actual value equals to the node value.
    # @param node [Node] the node
    # @return [Boolean] true if the actual value equals to the node value.
    def is_equal?(node)
      actual_value(node) == expected_value
    end

    # Get the actual value from ast node.
    # @param node [Node] ast node
    # @return the node value, could be integer, float, string, boolean, nil, range, and etc.
    def actual_value(node)
      if NodeQuery.adapter.is_node?(node)
        case NodeQuery.adapter.get_node_type(node)
        when :int, :float, :str, :sym
          NodeQuery.adapter.get_children(node).last
        when :true
          true
        when :false
          false
        when :nil
          nil
        when :array
          NodeQuery.adapter.get_children(node).map { |child_node| actual_value(child_node) }
        when :irange
          actual_value(NodeQuery.adapter.get_children(node).first)..actual_value(NodeQuery.adapter.get_children(node).last)
        when :erange
          actual_value(NodeQuery.adapter.get_children(node).first)...actual_value(NodeQuery.adapter.get_children(node).last)
        when :begin
          actual_value(NodeQuery.adapter.get_children(node).first)
        else
          node
        end
      else
        node
      end
    end

    # Get the expected value
    # @return expected value, could be integer, float, string, boolean, nil, range, and etc.
    def expected_value
      @value
    end

    # Check if the operator is valid.
    # @return [Boolean] true if the operator is valid
    def valid_operator?(operator)
      valid_operators.include?(operator)
    end
  end
end
