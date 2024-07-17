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
        expression = parser.parse('.def_node')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches node type and one attribute' do
        expression = parser.parse('.class_node[constant_path=User]')
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches nested attribute' do
        expression = parser.parse('.class_node[superclass.name=Base]')
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches method result' do
        expression = parser.parse('.def_node[parameters.requireds.size=2]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches multiple attributes' do
        expression = parser.parse('.def_node[parameters.requireds.size=2][parameters.requireds.0=id][parameters.requireds.1=name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches ^=' do
        expression = parser.parse('.def_node[name^=init]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches $=' do
        expression = parser.parse('.def_node[name$=ize]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches *=' do
        expression = parser.parse('.def_node[name*=ial]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches !=' do
        expression = parser.parse('.def_node[name!=foobar]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches =~' do
        expression = parser.parse('.def_node[name=~/init/]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches !~' do
        expression = parser.parse('.def_node[name!~/bar/]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches in' do
        expression = parser.parse('.instance_variable_write_node[name IN (@id @name)]')
        expect(expression.query_nodes(node)).to eq [
          node.body.first.body.body.first.body.body.first,
          node.body.first.body.body.first.body.body.last
        ]
      end

      it 'matches not in' do
        expression = parser.parse('.instance_variable_write_node[name NOT IN (@id @name)]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches includes' do
        expression = parser.parse('.def_node[parameters.requireds INCLUDES id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches includes with selector' do
        expression = parser.parse('.def_node[parameters.requireds INCLUDES .required_parameter_node[name=id]]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches not includes' do
        expression = parser.parse('.def_node[parameters.requireds NOT INCLUDES foobar]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches not includes with selector' do
        expression = parser.parse('.def_node[parameters.requireds NOT INCLUDES .required_parameter_node[name=foobar]]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches equal array' do
        expression = parser.parse('.def_node[parameters.requireds=(id name)]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]

        expression = parser.parse('.def_node[parameters.requireds=(name id)]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches not equal array' do
        expression = parser.parse('.def_node[parameters.requireds!=(id name)]')
        expect(expression.query_nodes(node)).to eq []

        expression = parser.parse('.def_node[parameters.requireds!=(name id)]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches nested selector' do
        expression = parser.parse('.def_node[body.body.0=.instance_variable_write_node]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches * in attribute key' do
        expression = parser.parse('.def_node[parameters.requireds.*.name=(id name)]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches descendant node' do
        expression = parser.parse('.class_node .instance_variable_write_node[name=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]
      end

      it 'matches three level descendant node' do
        expression = parser.parse('.class_node .def_node .instance_variable_write_node[name=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]
      end

      it 'matches child node' do
        expression = parser.parse('.instance_variable_write_node > .local_variable_read_node[name=id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first.value]
      end

      it 'matches next sibling node' do
        expression = parser.parse('.instance_variable_write_node[name=@id] + .instance_variable_write_node[name=@name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.last]
      end

      it 'matches sebsequent sibling node' do
        expression = parser.parse('.instance_variable_write_node[name=@id] ~ .instance_variable_write_node[name=@name]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.last]
      end

      it 'matches goto scope' do
        expression = parser.parse('.def_node body .instance_variable_write_node[name=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]
      end

      it 'matches multiple goto scope' do
        expression = parser.parse('.def_node body.body .instance_variable_write_node[name=@id]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]
      end

      it 'matches has selector' do
        expression = parser.parse('.def_node:has(.instance_variable_write_node[name=@id])')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches not_has selector' do
        expression = parser.parse('.def_node:not_has(.instance_variable_write_node[name=@id])')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches root has selector' do
        expression = parser.parse(':has(> .class_node)')
        expect(expression.query_nodes(node)).to eq [node]
      end

      it 'matches root not_has selector' do
        expression = parser.parse(':not_has(> .class_node)')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches >=' do
        expression = parser.parse('.def_node[parameters.requireds.size>=2]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches >' do
        expression = parser.parse('.def_node[parameters.requireds.size>2]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches <=' do
        expression = parser.parse('.def_node[parameters.requireds.size<=2]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches <' do
        expression = parser.parse('.def_node[parameters.requireds.size<2]')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches arguments' do
        expression = parser.parse('.call_node[arguments.arguments.size=2][arguments.arguments.first=.integer_node][arguments.arguments.last=.string_node]')
        expect(expression.query_nodes(node)).to eq [node.body.last.value]

        expression = parser.parse('.call_node[arguments.arguments.size=2][arguments.arguments.0=.integer_node][arguments.arguments.-1=.string_node]')
        expect(expression.query_nodes(node)).to eq [node.body.last.value]
      end

      it 'matches evaluated value' do
        expression = parser.parse('.instance_variable_write_node[name="@{{value}}"]')
        expect(expression.query_nodes(node)).to eq node.body.first.body.body.first.body.body
      end

      it 'matches evaluated value from base node' do
        expression = parser.parse('.def_node[name=initialize][body.body.0.name="@{{body.body.0.value}}"]')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches ,' do
        expression = parser.parse('.instance_variable_write_node[name=@id], .instance_variable_write_node[name=@name]')
        expect(expression.query_nodes(node)).to eq [
          node.body.first.body.body.first.body.body.first,
          node.body.first.body.body.first.body.body.last
        ]
      end

      it 'matches :first-child' do
        expression = parser.parse('.instance_variable_write_node:first-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]

        expression = parser.parse('.def_node .instance_variable_write_node:first-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.first]

        expression = parser.parse('.CommandCall:first-child')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches :last-child' do
        expression = parser.parse('.def_node .instance_variable_write_node:last-child')
        expect(expression.query_nodes(node)).to eq [node.body.first.body.body.first.body.body.last]

        expression = parser.parse('.CommandCall:last-child')
        expect(expression.query_nodes(node)).to eq []
      end

      it 'matches empty string' do
        node = prism_parse("call('')")
        expression = parser.parse(".call_node[message=call][arguments.arguments.first='']")
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches hash value' do
        node = prism_parse("{ foo: 'bar' }")
        expression = parser.parse(".hash_node[foo_value='bar']")
        expect(expression.query_nodes(node)).to eq [node.body.first]
      end
    end
  end
end
