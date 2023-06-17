require 'spec_helper'
require 'oedipus_lex'

RSpec.describe NodeQueryParser do
  let(:parser) { described_class.new }

  describe '#query_nodes' do
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
        expression = parser.parse(':has(> .ClassDeclaration)')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches root not_has selector' do
        expression = parser.parse(':not_has(> .ClassDeclaration)')
        expect(expression.query_nodes(node)).to eq []
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
