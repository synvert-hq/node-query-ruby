class NodeQueryParser
options no_result_var
token tCOMMA tNODE_TYPE tGOTO_SCOPE tKEY tIDENTIFIER_VALUE tPSEUDO_CLASS tRELATIONSHIP
      tOPEN_ATTRIBUTE tCLOSE_ATTRIBUTE tOPEN_ARRAY tCLOSE_ARRAY tOPEN_SELECTOR tCLOSE_SELECTOR tPOSITION
      tOPERATOR tARRAY_VALUE tBOOLEAN tFLOAT tINTEGER tNIL tREGEXP tSTRING tSYMBOL
rule
  expression_list
    : expression tCOMMA expression_list { NodeQuery::Compiler::ExpressionList.new(expression: val[0], rest: val[2]) }
    | expression { NodeQuery::Compiler::ExpressionList.new(expression: val[0]) }

  expression
    : selector expression { NodeQuery::Compiler::Expression.new(selector: val[0], rest: val[1]) }
    | selector { NodeQuery::Compiler::Expression.new(selector: val[0]) }

  selector
    : basic_selector tPOSITION { NodeQuery::Compiler::Selector.new(basic_selector: val[0], position: val[1], adapter: @adapter ) }
    | basic_selector { NodeQuery::Compiler::Selector.new(basic_selector: val[0], adapter: @adapter) }
    | tPSEUDO_CLASS tOPEN_SELECTOR selector tCLOSE_SELECTOR { NodeQuery::Compiler::Selector.new(pseudo_class: val[0], pseudo_selector: val[2], adapter: @adapter) }
    | tRELATIONSHIP selector { NodeQuery::Compiler::Selector.new(relationship: val[0], rest: val[1], adapter: @adapter) }
    | tGOTO_SCOPE selector { NodeQuery::Compiler::Selector.new(goto_scope: val[0], rest: val[1], adapter: @adapter) }

  basic_selector
    : tNODE_TYPE { NodeQuery::Compiler::BasicSelector.new(node_type: val[0], adapter: @adapter) }
    | tNODE_TYPE attribute_list { NodeQuery::Compiler::BasicSelector.new(node_type: val[0], attribute_list: val[1], adapter: @adapter) }

  attribute_list
    : attribute attribute_list { NodeQuery::Compiler::AttributeList.new(attribute: val[0], rest: val[1]) }
    | attribute { NodeQuery::Compiler::AttributeList.new(attribute: val[0]) }

  attribute
    : tOPEN_ATTRIBUTE tKEY tOPERATOR value tCLOSE_ATTRIBUTE { NodeQuery::Compiler::Attribute.new(key: val[1], value: val[3], operator: val[2], adapter: @adapter) }
    | tOPEN_ATTRIBUTE tKEY tOPERATOR tOPEN_ARRAY tCLOSE_ARRAY tCLOSE_ATTRIBUTE { NodeQuery::Compiler::Attribute.new(key: val[1], value: NodeQuery::Compiler::ArrayValue.new, operator: val[2], adapter: @adapter) }
    | tOPEN_ATTRIBUTE tKEY tOPERATOR tOPEN_ARRAY array_value tCLOSE_ARRAY tCLOSE_ATTRIBUTE { NodeQuery::Compiler::Attribute.new(key: val[1], value: val[4], operator: val[2], adapter: @adapter) }

  array_value
    : value array_value { NodeQuery::Compiler::ArrayValue.new(value: val[0], rest: val[1], adapter: @adapter) }
    | value { NodeQuery::Compiler::ArrayValue.new(value: val[0], adapter: @adapter) }

  value
    : selector
    | tBOOLEAN { NodeQuery::Compiler::Boolean.new(value: val[0], adapter: @adapter) }
    | tFLOAT { NodeQuery::Compiler::Float.new(value: val[0], adapter: @adapter) }
    | tINTEGER { NodeQuery::Compiler::Integer.new(value: val[0], adapter: @adapter) }
    | tNIL { NodeQuery::Compiler::Nil.new(value: val[0], adapter: @adapter) }
    | tREGEXP { NodeQuery::Compiler::Regexp.new(value: val[0], adapter: @adapter) }
    | tSTRING { NodeQuery::Compiler::String.new(value: val[0], adapter: @adapter) }
    | tSYMBOL { NodeQuery::Compiler::Symbol.new(value: val[0], adapter: @adapter) }
    | tIDENTIFIER_VALUE { NodeQuery::Compiler::Identifier.new(value: val[0], adapter: @adapter) }
end

---- inner
    def initialize(adapter:)
      @lexer = NodeQueryLexer.new
      @adapter = adapter
    end

    def parse string
      @lexer.parse string
      do_parse
    end

    def next_token
      @lexer.next_token
    end
