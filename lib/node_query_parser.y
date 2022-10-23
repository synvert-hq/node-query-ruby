class NodeQueryParser
options no_result_var
token tCOMMA tNODE_TYPE tGOTO_SCOPE tATTRIBUTE tKEY tIDENTIFIER tIDENTIFIER_VALUE tPSEUDO_CLASS tRELATIONSHIP
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
    : basic_selector tPOSITION { NodeQuery::Compiler::Selector.new(basic_selector: val[0], position: val[1] ) }
    | basic_selector { NodeQuery::Compiler::Selector.new(basic_selector: val[0]) }
    | tPSEUDO_CLASS tOPEN_SELECTOR selector tCLOSE_SELECTOR { NodeQuery::Compiler::Selector.new(pseudo_class: val[0], pseudo_selector: val[2]) }
    | tRELATIONSHIP selector { NodeQuery::Compiler::Selector.new(relationship: val[0], rest: val[1]) }
    | tGOTO_SCOPE selector { NodeQuery::Compiler::Selector.new(goto_scope: val[0], rest: val[1]) }

  basic_selector
    : tNODE_TYPE { NodeQuery::Compiler::BasicSelector.new(node_type: val[0]) }
    | tNODE_TYPE attribute_list { NodeQuery::Compiler::BasicSelector.new(node_type: val[0], attribute_list: val[1]) }

  attribute_list
    : tOPEN_ATTRIBUTE attribute tCLOSE_ATTRIBUTE attribute_list { NodeQuery::Compiler::AttributeList.new(attribute: val[1], rest: val[3]) }
    | tOPEN_ATTRIBUTE attribute tCLOSE_ATTRIBUTE { NodeQuery::Compiler::AttributeList.new(attribute: val[1]) }

  attribute
    : tKEY tOPERATOR value { NodeQuery::Compiler::Attribute.new(key: val[0], value: val[2], operator: val[1]) }
    | tKEY tOPERATOR tOPEN_ARRAY tCLOSE_ARRAY { NodeQuery::Compiler::Attribute.new(key: val[0], value: NodeQuery::Compiler::ArrayValue.new, operator: val[1]) }
    | tKEY tOPERATOR tOPEN_ARRAY array_value tCLOSE_ARRAY { NodeQuery::Compiler::Attribute.new(key: val[0], value: val[3], operator: val[1]) }

  array_value
    : value array_value { NodeQuery::Compiler::ArrayValue.new(value: val[0], rest: val[1]) }
    | value { NodeQuery::Compiler::ArrayValue.new(value: val[0]) }

  value
    : selector
    | tBOOLEAN { NodeQuery::Compiler::Boolean.new(value: val[0]) }
    | tFLOAT { NodeQuery::Compiler::Float.new(value: val[0]) }
    | tINTEGER { NodeQuery::Compiler::Integer.new(value: val[0])}
    | tNIL { NodeQuery::Compiler::Nil.new(value: val[0]) }
    | tREGEXP { NodeQuery::Compiler::Regexp.new(value: val[0]) }
    | tSTRING { NodeQuery::Compiler::String.new(value: val[0]) }
    | tSYMBOL { NodeQuery::Compiler::Symbol.new(value: val[0]) }
    | tIDENTIFIER_VALUE { NodeQuery::Compiler::Identifier.new(value: val[0]) }
end

---- inner
    def initialize
      @lexer = NodeQueryLexer.new
    end

    def parse string
      @lexer.parse string
      do_parse
    end

    def next_token
      @lexer.next_token
    end
