require 'spec_helper'
require 'oedipus_lex'

RSpec.describe NodeQueryParser do
  let(:parser) { described_class.new(adapter: NodeQuery::PrismAdapter.new) }

  describe '#query_nodes' do
    context 'prism' do
      let(:node) {
        prism_parse(<<~EOS)
          class User < Base
            def initialize(id, name)
              @id = id
              @name = name
            end
          end

          user = User.new(1, "Murphy")
        EOS
      }

      it 'matches node type' do
        expression = parser.parse('.DefNode')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches node type and one attribute' do
        expression = parser.parse('.ClassNode[constant_path=User]')
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches nested attribute' do
        expression = parser.parse('.ClassNode[superclass.name=Base]')
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches method result' do
        expression = parser.parse('.DefNode[parameters.requireds.size=2]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches multiple attributes' do
        expression = parser.parse('.DefNode[parameters.requireds.size=2][parameters.requireds.0=id][parameters.requireds.1=name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches ^=' do
        expression = parser.parse('.DefNode[name^=init]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches $=' do
        expression = parser.parse('.DefNode[name$=ize]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches *=' do
        expression = parser.parse('.DefNode[name*=ial]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches !=' do
        expression = parser.parse('.DefNode[name!=foobar]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches =~' do
        expression = parser.parse('.DefNode[name=~/init/]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches !~' do
        expression = parser.parse('.DefNode[name!~/bar/]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches in' do
        expression = parser.parse('.InstanceVariableWriteNode[name IN (@id @name)]')
        expect(expression.query_nodes(node)).to eq [
          node.body.first.body.body.first.body.body.first,
          node.body.first.body.body.first.body.body.last
        ]
      end

      it 'matches not in' do
        expression = parser.parse('.InstanceVariableWriteNode[name NOT IN (@id @name)]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches includes' do
        expression = parser.parse('.DefNode[parameters.requireds INCLUDES id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches includes with selector' do
        expression = parser.parse('.DefNode[parameters.requireds INCLUDES .RequiredParameterNode[name=id]]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches not includes' do
        expression = parser.parse('.DefNode[parameters.requireds NOT INCLUDES foobar]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches not includes with selector' do
        expression = parser.parse('.DefNode[parameters.requireds NOT INCLUDES .RequiredParameterNode[name=foobar]]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches equal array' do
        expression = parser.parse('.DefNode[parameters.requireds=(id name)]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]

        expression = parser.parse('.DefNode[parameters.requireds=(name id)]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches not equal array' do
        expression = parser.parse('.DefNode[parameters.requireds!=(id name)]')
        expect(expression.query_nodes(node)).to eq []

        expression = parser.parse('.DefNode[parameters.requireds!=(name id)]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches nested selector' do
        expression = parser.parse('.DefNode[body.body.0=.InstanceVariableWriteNode]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches * in attribute key' do
        expression = parser.parse('.DefNode[parameters.requireds.*.name=(id name)]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches descendant node' do
        expression = parser.parse('.ClassNode .InstanceVariableWriteNode[name=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]
      end

      it 'matches three level descendant node' do
        expression = parser.parse('.ClassNode .DefNode .InstanceVariableWriteNode[name=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]
      end

      it 'matches child node' do
        expression = parser.parse('.InstanceVariableWriteNode > .LocalVariableReadNode[name=id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first.value]
      end

      it 'matches next sibling node' do
        expression = parser.parse('.InstanceVariableWriteNode[name=@id] + .InstanceVariableWriteNode[name=@name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.last]
      end

      it 'matches sebsequent sibling node' do
        expression = parser.parse('.InstanceVariableWriteNode[name=@id] ~ .InstanceVariableWriteNode[name=@name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.last]
      end

      it 'matches goto scope' do
        expression = parser.parse('.DefNode body .InstanceVariableWriteNode[name=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]
      end

      it 'matches multiple goto scope' do
        expression = parser.parse('.DefNode body.body .InstanceVariableWriteNode[name=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]
      end

      it 'matches has selector' do
        expression = parser.parse('.DefNode:has(.InstanceVariableWriteNode[name=@id])')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches not_has selector' do
        expression = parser.parse('.DefNode:not_has(.InstanceVariableWriteNode[name=@id])')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches root has selector' do
        expression = parser.parse(':has(> .ClassNode)')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches root not_has selector' do
        expression = parser.parse(':not_has(> .ClassNode)')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches >=' do
        expression = parser.parse('.DefNode[parameters.requireds.size>=2]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches >' do
        expression = parser.parse('.DefNode[parameters.requireds.size>2]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches <=' do
        expression = parser.parse('.DefNode[parameters.requireds.size<=2]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches <' do
        expression = parser.parse('.DefNode[parameters.requireds.size<2]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches arguments' do
        expression = parser.parse('.CallNode[arguments.arguments.size=2][arguments.arguments.first=.IntegerNode][arguments.arguments.last=.StringNode]')
        expect(expression.query_nodes(node)).to eq [node.body.last.value]

        expression = parser.parse('.CallNode[arguments.arguments.size=2][arguments.arguments.0=.IntegerNode][arguments.arguments.-1=.StringNode]')
        expect(expression.query_nodes(node)).to eq [node.body.last.value]
      end

      it 'matches evaluated value' do
        expression = parser.parse('.InstanceVariableWriteNode[name="@{{value}}"]')
        expect(expression.query_nodes(node)).to eq node.body.first.body.body.first.body.body
      end

      it 'matches evaluated value from base node' do
        expression = parser.parse('.DefNode[name=initialize][body.body.0.name="@{{body.body.0.value}}"]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches ,' do
        expression = parser.parse('.InstanceVariableWriteNode[name=@id], .InstanceVariableWriteNode[name=@name]')
        expect(expression.query_nodes(node)).to eq [
          node.body.first.body.body.first.body.body.first,
          node.body.first.body.body.first.body.body.last
        ]
      end

      it 'matches :first-child' do
        expression = parser.parse('.InstanceVariableWriteNode:first-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]

        expression = parser.parse('.DefNode .InstanceVariableWriteNode:first-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]

        expression = parser.parse('.CommandCall:first-child')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches :last-child' do
        expression = parser.parse('.DefNode .InstanceVariableWriteNode:last-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.last]

        expression = parser.parse('.CommandCall:last-child')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches empty string' do
        node = prism_parse("call('')")
        expression = parser.parse(".CallNode[message=call][arguments.arguments.first='']")
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches hash value' do
        node = prism_parse("{ foo: 'bar' }")
        expression = parser.parse(".HashNode[foo_value='bar']")
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end
    end
  end
end
