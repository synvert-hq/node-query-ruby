require 'spec_helper'
require 'oedipus_lex'

RSpec.describe NodeQueryParser do
  let(:parser) { described_class.new }

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
        expression = parser.parse(':has(> .class)')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches root not_has selector' do
        expression = parser.parse(':not_has(> .class)')
        expect(expression.query_nodes(node)).to eq []
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
  end
end
