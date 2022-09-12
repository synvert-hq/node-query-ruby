# frozen_string_literal: true

module NodeQuery::Compiler
  autoload :InvalidOperatorError, 'node_query/compiler/invalid_operator_error'
  autoload :ParseError, 'node_query/compiler/parse_error'

  autoload :Comparable, 'node_query/compiler/comparable'

  autoload :ExpressionList, 'node_query/compiler/expression_list'
  autoload :Expression, 'node_query/compiler/expression'
  autoload :Selector, 'node_query/compiler/selector'
  autoload :BasicSelector, 'node_query/compiler/basic_selector'
  autoload :AttributeList, 'node_query/compiler/attribute_list'
  autoload :Attribute, 'node_query/compiler/attribute'

  autoload :ArrayValue, 'node_query/compiler/array_value'
  autoload :Boolean, 'node_query/compiler/boolean'
  autoload :Float, 'node_query/compiler/float'
  autoload :Identifier, 'node_query/compiler/identifier'
  autoload :Integer, 'node_query/compiler/integer'
  autoload :Nil, 'node_query/compiler/nil'
  autoload :Regexp, 'node_query/compiler/regexp'
  autoload :String, 'node_query/compiler/string'
  autoload :Symbol, 'node_query/compiler/symbol'
end
