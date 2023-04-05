# frozen_string_literal: true

module NodeQuery::Compiler
  # Compare acutal value with expected value.
  module Comparable
    SIMPLE_VALID_OPERATORS = ['==', '!=', 'includes', 'not_includes']
    STRING_VALID_OPERATORS = ['==', '!=', '^=', '$=', '*=', 'includes', 'not_includes']
    NUMBER_VALID_OPERATORS = ['==', '!=', '>', '>=', '<', '<=', 'includes', 'not_includes']
    ARRAY_VALID_OPERATORS = ['==', '!=', 'in', 'not_in']
    REGEXP_VALID_OPERATORS = ['=~', '!~']

    # Check if the actual value matches the expected value.
    #
    # @param node [Node] node to calculate actual value
    # @param base_node [Node] the base node for evaluated value
    # @param operator [String] operator to compare with expected value, operator can be <code>'=='</code>, <code>'!='</code>, <code>'>'</code>, <code>'>='</code>, <code>'<'</code>, <code>'<='</code>, <code>'includes'</code>, <code>'in'</code>, <code>'not_in'</code>, <code>'=~'</code>, <code>'!~'</code>
    # @return [Boolean] true if actual value matches the expected value
    # @raise [NodeQuery::Compiler::InvalidOperatorError] if operator is invalid
    def match?(node, base_node, operator)
      raise InvalidOperatorError, "invalid operator #{operator}" unless valid_operator?(operator)

      actual = actual_value(node)
      expected = expected_value(base_node)
      case operator
      when '!='
        if expected.is_a?(::Array)
          !actual.is_a?(::Array) || actual.size != expected.size ||
            actual.zip(expected).any? { |actual_child, expected_child|
              expected_child.match?(actual_child, base_node, '!=')
            }
        else
          !is_equal?(actual, expected)
        end
      when '=~'
        actual =~ expected
      when '!~'
        actual !~ expected
      when '^='
        actual.start_with?(expected)
      when '$='
        actual.end_with?(expected)
      when '*='
        actual.include?(expected)
      when '>'
        actual > expected
      when '>='
        actual >= expected
      when '<'
        actual < expected
      when '<='
        actual <= expected
      when 'in'
        if node.is_a?(Array)
          node.all? { |child| expected.any? { |expected_child| expected_child.match?(child, base_node, '==') } }
        else
          expected.any? { |expected_child| expected_child.match?(node, base_node, '==') }
        end
      when 'not_in'
        if node.is_a?(Array)
          node.all? { |child| expected.all? { |expected_child| expected_child.match?(child, base_node, '!=') } }
        else
          expected.all? { |expected_child| expected_child.match?(node, base_node, '!=') }
        end
      when 'includes'
        actual.any? { |actual_child| expected.match?(actual_child) }
      when 'not_includes'
        actual.none? { |actual_child| expected.match?(actual_child) }
      else
        if expected.is_a?(::Array)
          actual.is_a?(::Array) && actual.size == expected.size &&
            actual.zip(expected).all? { |actual_child, expected_child|
              expected_child.match?(actual_child, base_node, '==')
            }
        else
          is_equal?(actual, expected)
        end
      end
    end

    # Check if the actual value equals the expected value.
    # @param acutal
    # @param expected
    # @return [Boolean] true if the actual value equals the expected value.
    def is_equal?(actual, expected)
      actual == expected
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
    # @param base_node [Node] the base node for evaluated value
    # @return expected value, could be integer, float, string, boolean, nil, range, and etc.
    def expected_value(_base_node)
      @value
    end

    # Check if the operator is valid.
    # @return [Boolean] true if the operator is valid
    def valid_operator?(operator)
      valid_operators.include?(operator)
    end
  end
end
