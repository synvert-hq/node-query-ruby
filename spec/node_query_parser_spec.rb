require 'spec_helper'
require 'oedipus_lex'

RSpec.describe NodeQueryParser do
  let(:parser) { described_class.new }

  describe '#toString' do
    it 'parses node ype' do
      source = '.send'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses one selector' do
      source = '.send[message=:create]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses two selectors' do
      source = '.class[name=Synvert] .def[name="foobar"]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses three selectors' do
      source = '.class[name=Synvert] .def[name="foobar"] .send[message=create]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses child selector' do
      source = '.class[name=Synvert] > .def[name="foobar"]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :has pseduo class selector' do
      source = '.class :has(> .def)'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :not_has pseduo class selector' do
      source = '.class :not_has(> .def)'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses multiple attributes' do
      source = '.send[receiver=nil][message=:create]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses nested selector' do
      source = '.def[body.0=.send[message=create]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses selector value' do
      source = '.send[receiver=.send[message=:create]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses ^= operator' do
      source = '.def[name^=synvert]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses $= operator' do
      source = '.def[name$=synvert]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses *= operator' do
      source = '.def[name*=synvert]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses != operator' do
      source = '.send[receiver=.send[message!=:create]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses > operator' do
      source = '.send[receiver=.send[arguments.size>1]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses >= operator' do
      source = '.send[receiver=.send[arguments.size>=1]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses < operator' do
      source = '.send[receiver=.send[arguments.size<1]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses <= operator' do
      source = '.send[receiver=.send[arguments.size<=1]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses in operator' do
      source = '.def[name in (foo bar)]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses not in operator' do
      source = '.def[name not in (foo bar)]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses includes operator' do
      source = '.def[arguments includes &block]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses not includes operator' do
      source = '.def[arguments not includes &block]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses empty string' do
      source = '.send[arguments.first=""]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses []=' do
      source = '.send[message=[]=]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :[]' do
      source = '.send[message=:[]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses goto scope' do
      source = '.block body > .send'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses * in key' do
      source = '.def[arguments.*.name in (foo bar)]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses ,' do
      source = '.send[message=foo], .send[message=bar]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :first-child' do
      source = '.send[message=foo]:first-child'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :last-child' do
      source = '.send[message=foo]:last-child'
      expect(parser.parse(source).to_s).to eq source
    end
  end

  describe '#query_nodes' do
    context 'parser' do
      let(:node) {
        parse(<<~EOS)
          class User < Base
            def initialize(id, name)
              @id = id
              @name = name
            end
          end

          user = User.new(1, "Murphy")
        EOS
      }

      before do
        NodeQuery.configure(adapter: NodeQuery::ParserAdapter.new)
      end

      it 'matches node type' do
        expression = parser.parse('.def')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches node type and one attribute' do
        expression = parser.parse('.class[name=User]')
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches nested attribute' do
        expression = parser.parse('.class[parent_class.name=Base]')
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches method result' do
        expression = parser.parse('.def[arguments.size=2]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches multiple attributes' do
        expression = parser.parse('.def[arguments.size=2][arguments.0=id][arguments.1=name]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches ^=' do
        expression = parser.parse('.def[name^=init]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches $=' do
        expression = parser.parse('.def[name$=ize]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches *=' do
        expression = parser.parse('.def[name*=ial]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches !=' do
        expression = parser.parse('.def[name!=foobar]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches =~' do
        expression = parser.parse('.def[name=~/init/]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches !~' do
        expression = parser.parse('.def[name!~/bar/]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches in' do
        expression = parser.parse('.ivasgn[variable IN (@id @name)]')
        expect(expression.query_nodes(node)).to eq node.body.first.body.first.body
      end

      it 'matches not in' do
        expression = parser.parse('.ivasgn[variable NOT IN (@id @name)]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches includes' do
        expression = parser.parse('.def[arguments INCLUDES id]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches includes with selector' do
        expression = parser.parse('.def[arguments INCLUDES .arg[name=id]]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches not includes' do
        expression = parser.parse('.def[arguments NOT INCLUDES foobar]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches not includes with selector' do
        expression = parser.parse('.def[arguments NOT INCLUDES .arg[name=foobar]]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches equal array' do
        expression = parser.parse('.def[arguments=(id name)]')
        expect(expression.query_nodes(node)).to eq node.body.first.body

        expression = parser.parse('.def[arguments=(name id)]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches not equal array' do
        expression = parser.parse('.def[arguments!=(id name)]')
        expect(expression.query_nodes(node)).to eq []

        expression = parser.parse('.def[arguments!=(name id)]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches nested selector' do
        expression = parser.parse('.def[body.0=.ivasgn]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches * in attribute key' do
        expression = parser.parse('.def[arguments.*.name=(id name)]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches descendant node' do
        expression = parser.parse('.class .ivasgn[variable=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body.first]
      end

      it 'matches three level descendant node' do
        expression = parser.parse('.class .def .ivasgn[variable=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body.first]
      end

      it 'matches child node' do
        expression = parser.parse('.def > .ivasgn[variable=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body.first]
      end

      it 'matches next sibling node' do
        expression = parser.parse('.ivasgn[variable=@id] + .ivasgn[variable=@name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body[1]]
      end

      it 'matches sebsequent sibling node' do
        expression = parser.parse('.ivasgn[variable=@id] ~ .ivasgn[variable=@name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body[1]]
      end

      it 'matches goto scope' do
        expression = parser.parse('.def body > .ivasgn[variable=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body.first]

        expression = parser.parse('.def body .ivasgn[variable=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body.first]
      end

      it 'matches multiple goto scope' do
        node = parse("RSpec.describe User do\nend")
        expression = parser.parse('.block caller.arguments .const[name=User]')
        expect(expression.query_nodes(node)).to eq [node.caller.arguments.first]
      end

      it 'matches has selector' do
        expression = parser.parse('.def:has(> .ivasgn[variable=@id])')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first]
      end

      it 'matches not_has selector' do
        expression = parser.parse('.def:not_has(> .ivasgn[variable=@id])')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches root has selector' do
        expression = parser.parse(':has(.def[name=initialize])')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches >=' do
        expression = parser.parse('.def[arguments.size>=2]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches >' do
        expression = parser.parse('.def[arguments.size>2]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches <=' do
        expression = parser.parse('.def[arguments.size<=2]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches <' do
        expression = parser.parse('.def[arguments.size<2]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches arguments' do
        expression = parser.parse('.send[arguments.size=2][arguments.first=.int][arguments.last=.str]')
        expect(expression.query_nodes(node)).to eq [node.body.last.value]

        expression = parser.parse('.send[arguments.size=2][arguments.0=.int][arguments.-1=.str]')
        expect(expression.query_nodes(node)).to eq [node.body.last.value]
      end

      it 'matches evaluated value' do
        expression = parser.parse('.ivasgn[variable="@{{value}}"]')
        expect(expression.query_nodes(node)).to eq node.body.first.body.first.body
      end

      it 'matches evaluated value from base node' do
        expression = parser.parse('.def[name=initialize][body.0.variable="@{{body.0.value}}"]')
        expect(expression.query_nodes(node)).to eq node.body.first.body
      end

      it 'matches ,' do
        expression = parser.parse('.ivasgn[variable=@id], .ivasgn[variable=@name]')
        expect(expression.query_nodes(node)).to eq node.body.first.body.first.body
      end

      it 'matches :first-child' do
        expression = parser.parse('.ivasgn:first-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body.first]

        expression = parser.parse('.def > .ivasgn:first-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body.first]

        expression = parser.parse('.block:first-child')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches :last-child' do
        expression = parser.parse('.ivasgn:last-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body.last]

        expression = parser.parse('.def > .ivasgn:last-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.first.body.last]

        expression = parser.parse('.block:last-child')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches []' do
        node = parse("user[:error]")
        expression = parser.parse('.send[message=[]]')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches []=' do
        node = parse("user[:error] = 'error'")
        expression = parser.parse('.send[message=:[]=]')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches nil and nil?' do
        node = parse("nil.nil?")
        expression = parser.parse('.send[receiver=nil][message=nil?]')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches empty string' do
        node = parse("call('')")
        expression = parser.parse('.send[message=call][arguments.first=""]')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches hash value' do
        node = parse("{ foo: 'bar' }")
        expression = parser.parse(".hash[foo_value='bar']")
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'sets option including_self to false' do
        expression = parser.parse('.class')
        expect(expression.query_nodes(node.children.first, { including_self: false })).to eq []

        expect(expression.query_nodes(node.children.first)).to eq [node.children.first]
      end

      it 'sets options stop_at_first_match to true' do
        expression = parser.parse('.ivasgn')
        expect(
          expression.query_nodes(
            node.children.first,
            { stop_at_first_match: true }
          )
        ).to eq [node.children.first.body.first.body.first]

        expect(expression.query_nodes(node.children.first)).to eq node.children.first.body.first.body
      end

      it 'sets options recursive to false' do
        expression = parser.parse('.def')
        expect(expression.query_nodes(node, { recursive: false })).to eq []

        expect(expression.query_nodes(node)).to eq [node.children.first.body.first]
      end
    end

    context 'syntax_tree' do
      let(:node) {
        syntax_tree_parse(<<~EOS)
          class User < Base
            def initialize(id, name)
              @id = id
              @name = name
            end
          end

          user = User.new(1, "Murphy")
        EOS
      }

      before do
        NodeQuery.configure(adapter: NodeQuery::SyntaxTreeAdapter.new)
      end

      it 'matches node type' do
        expression = parser.parse('.DefNode')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches node type and one attribute' do
        expression = parser.parse('.ClassDeclaration[constant=User]')
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches nested attribute' do
        expression = parser.parse('.ClassDeclaration[superclass.value=Base]')
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches method result' do
        expression = parser.parse('.DefNode[params.contents.requireds.size=2]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches multiple attributes' do
        expression = parser.parse('.DefNode[params.contents.requireds.size=2][params.contents.requireds.0=id][params.contents.requireds.1=name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches ^=' do
        expression = parser.parse('.DefNode[name^=init]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches $=' do
        expression = parser.parse('.DefNode[name$=ize]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches *=' do
        expression = parser.parse('.DefNode[name*=ial]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches !=' do
        expression = parser.parse('.DefNode[name!=foobar]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches =~' do
        expression = parser.parse('.DefNode[name=~/init/]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches !~' do
        expression = parser.parse('.DefNode[name!~/bar/]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches in' do
        expression = parser.parse('.IVar[value IN (@id @name)]')
        expect(expression.query_nodes(node)).to eq [
          node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first.target.value,
          node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.last.target.value
        ]
      end

      it 'matches not in' do
        expression = parser.parse('.IVar[value NOT IN (@id @name)]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches includes' do
        expression = parser.parse('.DefNode[params.contents.requireds INCLUDES id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches includes with selector' do
        expression = parser.parse('.DefNode[params.contents.requireds INCLUDES .Ident[value=id]]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches not includes' do
        expression = parser.parse('.DefNode[params.contents.requireds NOT INCLUDES foobar]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches not includes with selector' do
        expression = parser.parse('.DefNode[params.contents.requireds NOT INCLUDES .Ident[value=foobar]]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches equal array' do
        expression = parser.parse('.DefNode[params.contents.requireds=(id name)]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]

        expression = parser.parse('.DefNode[params.contents.requireds=(name id)]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches not equal array' do
        expression = parser.parse('.DefNode[params.contents.requireds!=(id name)]')
        expect(expression.query_nodes(node)).to eq []

        expression = parser.parse('.DefNode[params.contents.requireds!=(name id)]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches nested selector' do
        expression = parser.parse('.DefNode[bodystmt.statements.body.0=.Assign]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches * in attribute key' do
        expression = parser.parse('.DefNode[params.contents.requireds.*.value=(id name)]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches descendant node' do
        expression = parser.parse('.ClassDeclaration .IVar[value=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first.target.value]
      end

      it 'matches three level descendant node' do
        expression = parser.parse('.ClassDeclaration .DefNode .IVar[value=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first.target.value]
      end

      it 'matches child node' do
        expression = parser.parse('.Assign > .VarField[value=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first.target]
      end

      it 'matches next sibling node' do
        expression = parser.parse('.Assign[target=@id] + .Assign[target=@name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.last]
      end

      it 'matches sebsequent sibling node' do
        expression = parser.parse('.Assign[target=@id] ~ .Assign[target=@name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.last]
      end

      it 'matches goto scope' do
        expression = parser.parse('.DefNode bodystmt .IVar[value=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first.target.value]
      end

      it 'matches multiple goto scope' do
        expression = parser.parse('.DefNode bodystmt.statements.body .IVar[value=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first.target.value]
      end

      it 'matches has selector' do
        expression = parser.parse('.DefNode:has(.IVar[value=@id])')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches not_has selector' do
        expression = parser.parse('.DefNode:not_has(.IVar[value=@id])')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches root has selector' do
        expression = parser.parse(':has(.DefNode[name=initialize])')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches >=' do
        expression = parser.parse('.DefNode[params.contents.requireds.size>=2]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches >' do
        expression = parser.parse('.DefNode[params.contents.requireds.size>2]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches <=' do
        expression = parser.parse('.DefNode[params.contents.requireds.size<=2]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches <' do
        expression = parser.parse('.DefNode[params.contents.requireds.size<2]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches arguments' do
        expression = parser.parse('.CallNode[arguments.arguments.parts.size=2][arguments.arguments.parts.first=.Int][arguments.arguments.parts.last=.StringLiteral]')
        expect(expression.query_nodes(node)).to eq [node.body.last.value]

        expression = parser.parse('.CallNode[arguments.arguments.parts.size=2][arguments.arguments.parts.0=.Int][arguments.arguments.parts.-1=.StringLiteral]')
        expect(expression.query_nodes(node)).to eq [node.body.last.value]
      end

      it 'matches evaluated value' do
        expression = parser.parse('.Assign[target="@{{value}}"]')
        expect(expression.query_nodes(node)).to eq node.body.first.bodystmt.statements.body.first.bodystmt.statements.body
      end

      it 'matches evaluated value from base node' do
        expression = parser.parse('.DefNode[name=initialize][bodystmt.statements.body.0.target="@{{bodystmt.statements.body.0.value}}"]')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches ,' do
        expression = parser.parse('.IVar[value=@id], .IVar[value=@name]')
        expect(expression.query_nodes(node)).to eq [
          node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first.target.value,
          node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.last.target.value
        ]
      end

      it 'matches :first-child' do
        expression = parser.parse('.Assign:first-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first]

        expression = parser.parse('.DefNode .Assign:first-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first]

        expression = parser.parse('.CommandCall:first-child')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches :last-child' do
        expression = parser.parse('.DefNode .Assign:last-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.last]

        expression = parser.parse('.CommandCall:last-child')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches empty string' do
        node = syntax_tree_parse("call('')")
        expression = parser.parse(".CallNode[message=call][arguments.arguments.parts.first='']")
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches hash value' do
        node = syntax_tree_parse("{ foo: 'bar' }")
        expression = parser.parse(".HashLiteral[foo_value='bar']")
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end
    end
  end
end
