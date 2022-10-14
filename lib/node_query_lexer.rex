class NodeQueryLexer

macros
  OPEN_ATTRIBUTE           /\[/
  CLOSE_ATTRIBUTE          /\]/
  OPEN_ARRAY               /\(/
  CLOSE_ARRAY              /\)/
  OPEN_SELECTOR            /\(/
  CLOSE_SELECTOR           /\)/
  NODE_TYPE                /\.[a-z]+/
  IDENTIFIER               /[@\*\.\w]*\w/
  IDENTIFIER_VALUE         /[@\.\w!&:\?<>=]+/
  FALSE                    /false/
  FLOAT                    /\d+\.\d+/
  INTEGER                  /\d+/
  NIL                      /nil/
  REGEXP_BODY              /(?:[^\/]|\\\/)*/
  REGEXP                   /\/(#{REGEXP_BODY})(?<!\\)\/([imxo]*)/
  SYMBOL                   /:[\w!\?<>=]+/
  TRUE                     /true/
  SINGLE_QUOTE_STRING      /'.*?'/
  DOUBLE_QUOTE_STRING      /".*?"/

rules

# [:state]          pattern                       [actions]
                    /\s+/
                    /,/                           { [:tCOMMA, text] }
                    /:first-child/                { [:tPOSITION, text[1..-1]] }
                    /:last-child/                 { [:tPOSITION, text[1..-1]] }
                    /:has/                        { [:tPSEUDO_CLASS, text[1..-1]] }
                    /:not_has/                    { [:tPSEUDO_CLASS, text[1..-1]] }
                    /#{NODE_TYPE}/                { [:tNODE_TYPE, text[1..]] }
                    /#{IDENTIFIER}/               { [:tGOTO_SCOPE, text] }
                    />/                           { [:tRELATIONSHIP, text] }
                    /~/                           { [:tRELATIONSHIP, text] }
                    /\+/                          { [:tRELATIONSHIP, text] }
                    /#{OPEN_SELECTOR}/            { [:tOPEN_SELECTOR, text] }
                    /#{CLOSE_SELECTOR}/           { [:tCLOSE_SELECTOR, text] }
                    /#{OPEN_ATTRIBUTE}/           { @nested_count += 1; @state = :KEY; [:tOPEN_ATTRIBUTE, text] }
:KEY                /\s+/
:KEY                /\^=/                         { @state = :VALUE; [:tOPERATOR, '^='] }
:KEY                /\$=/                         { @state = :VALUE; [:tOPERATOR, '$='] }
:KEY                /\*=/                         { @state = :VALUE; [:tOPERATOR, '*='] }
:KEY                /!=/                          { @state = :VALUE; [:tOPERATOR, '!='] }
:KEY                /=~/                          { @state = :VALUE; [:tOPERATOR, '=~'] }
:KEY                /!~/                          { @state = :VALUE; [:tOPERATOR, '!~'] }
:KEY                />=/                          { @state = :VALUE; [:tOPERATOR, '>='] }
:KEY                /<=/                          { @state = :VALUE; [:tOPERATOR, '<='] }
:KEY                />/                           { @state = :VALUE; [:tOPERATOR, '>'] }
:KEY                /</                           { @state = :VALUE; [:tOPERATOR, '<'] }
:KEY                /=/                           { @state = :VALUE; [:tOPERATOR, '=='] }
:KEY                /includes/i                   { @state = :VALUE; [:tOPERATOR, 'includes'] }
:KEY                /not in/i                     { @state = :VALUE; [:tOPERATOR, 'not_in'] }
:KEY                /in/i                         { @state = :VALUE; [:tOPERATOR, 'in'] }
:KEY                /#{IDENTIFIER}/               { [:tKEY, text] }
:VALUE              /\s+/
:VALUE              /\[\]=/                       { [:tIDENTIFIER_VALUE, text] }
:VALUE              /\[\]/                        { [:tIDENTIFIER_VALUE, text] }
:VALUE              /:\[\]=/                      { [:tSYMBOL, text[1..-1].to_sym] }
:VALUE              /:\[\]/                       { [:tSYMBOL, text[1..-1].to_sym] }
:VALUE              /#{OPEN_ARRAY}/               { @state = :ARRAY_VALUE; [:tOPEN_ARRAY, text] }
:VALUE              /#{CLOSE_ATTRIBUTE}/          { @nested_count -= 1; @state = @nested_count == 0 ? nil : :VALUE; [:tCLOSE_ATTRIBUTE, text] }
:VALUE              /#{NIL}\?/                    { [:tIDENTIFIER_VALUE, text] }
:VALUE              /#{NIL}/                      { [:tNIL, nil] }
:VALUE              /#{TRUE}/                     { [:tBOOLEAN, true] }
:VALUE              /#{FALSE}/                    { [:tBOOLEAN, false] }
:VALUE              /#{SYMBOL}/                   { [:tSYMBOL, text[1..-1].to_sym] }
:VALUE              /#{FLOAT}/                    { [:tFLOAT, text.to_f] }
:VALUE              /#{INTEGER}/                  { [:tINTEGER, text.to_i] }
:VALUE              /#{REGEXP}/                   { [:tREGEXP, eval(text)] }
:VALUE              /#{DOUBLE_QUOTE_STRING}/      { [:tSTRING, text[1...-1]] }
:VALUE              /#{SINGLE_QUOTE_STRING}/      { [:tSTRING, text[1...-1]] }
:VALUE              /#{NODE_TYPE}/                { [:tNODE_TYPE, text[1..]] }
:VALUE              /#{OPEN_ATTRIBUTE}/           { @nested_count += 1; @state = :KEY; [:tOPEN_ATTRIBUTE, text] }
:VALUE              /#{IDENTIFIER_VALUE}/         { [:tIDENTIFIER_VALUE, text] }
:ARRAY_VALUE        /\s+/
:ARRAY_VALUE        /#{CLOSE_ARRAY}/              { @state = :VALUE; [:tCLOSE_ARRAY, text] }
:ARRAY_VALUE        /#{NIL}\?/                    { [:tIDENTIFIER_VALUE, text] }
:ARRAY_VALUE        /#{NIL}/                      { [:tNIL, nil] }
:ARRAY_VALUE        /#{TRUE}/                     { [:tBOOLEAN, true] }
:ARRAY_VALUE        /#{FALSE}/                    { [:tBOOLEAN, false] }
:ARRAY_VALUE        /#{SYMBOL}/                   { [:tSYMBOL, text[1..-1].to_sym] }
:ARRAY_VALUE        /#{FLOAT}/                    { [:tFLOAT, text.to_f] }
:ARRAY_VALUE        /#{INTEGER}/                  { [:tINTEGER, text.to_i] }
:ARRAY_VALUE        /#{REGEXP}/                   { [:tREGEXP, eval(text)] }
:ARRAY_VALUE        /#{DOUBLE_QUOTE_STRING}/      { [:tSTRING, text[1...-1]] }
:ARRAY_VALUE        /#{SINGLE_QUOTE_STRING}/      { [:tSTRING, text[1...-1]] }
:ARRAY_VALUE        /#{IDENTIFIER_VALUE}/         { [:tIDENTIFIER_VALUE, text] }

inner
  def initialize
    @nested_count = 0
  end

  def do_parse; end
end