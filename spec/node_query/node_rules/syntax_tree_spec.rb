require 'spec_helper'

RSpec.describe NodeQuery::NodeRules do
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
        rules = described_class.new({ node_type: 'DefNode' })
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches node type and one attribute' do
        rules = described_class.new({ node_type: 'ClassDeclaration', constant: 'User' })
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches multiple attributes' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            params: { contents: { requireds: { size: 2, '0': 'id', '1': 'name' } } }
          }
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches nested attribute' do
        rules = described_class.new({ node_type: 'ClassDeclaration', superclass: { value: 'Base' } })
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches not' do
        rules = described_class.new({ node_type: 'DefNode', name: { not: 'foobar' } })
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches regex' do
        rules = described_class.new({ node_type: 'DefNode', name: /init/ })
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches regex not' do
        rules = described_class.new({ node_type: 'DefNode', name: { not: /foobar/ } })
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches in' do
        rules = described_class.new({ node_type: 'IVar', value: { in: ['@id', '@name'] } })
        expect(rules.query_nodes(node)).to eq [
          node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.first.target.value,
          node.body.first.bodystmt.statements.body.first.bodystmt.statements.body.last.target.value
        ]
      end

      it 'matches not_in' do
        rules = described_class.new({ node_type: 'IVar', value: { not_in: ['@id', '@name'] } })
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches includes' do
        rules = described_class.new({ node_type: 'DefNode', params: { contents: { requireds: { includes: 'id' } } } })
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches not_includes' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            params: { contents: { requireds: { not_includes: 'foobar' } } }
          }
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches equal array' do
        rules = described_class.new({ node_type: 'DefNode', params: { contents: { requireds: ['id', 'name'] } } })
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]

        rules = described_class.new({ node_type: 'DefNode', params: { contents: { requireds: ['name', 'id'] } } })
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches not equal array' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            params: { contents: { requireds: { not: ['id', 'name'] } } }
          }
        )
        expect(rules.query_nodes(node)).to eq []

        rules = described_class.new(
          {
            node_type: 'DefNode',
            params: { contents: { requireds: { not: ['name', 'id'] } } }
          }
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches nested selector' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            bodystmt: { statements: { body: { '0': { node_type: 'Assign' } } } }
          }
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches gte' do
        rules = described_class.new({ node_type: 'DefNode', params: { contents: { requireds: { size: { gte: 2 } } } } })
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches gt' do
        rules = described_class.new({ node_type: 'DefNode', params: { contents: { requireds: { size: { ge: 2 } } } } })
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches lte' do
        rules = described_class.new({ node_type: 'DefNode', params: { contents: { requireds: { size: { lte: 2 } } } } })
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches lt' do
        rules = described_class.new({ node_type: 'DefNode', params: { contents: { requireds: { size: { lt: 2 } } } } })
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches arguments' do
        rules = described_class.new(
          {
            node_type: 'CallNode',
            arguments: {
              arguments: {
                parts: {
                  size: 2,
                  first: { node_type: 'Int' },
                  last: { node_type: 'StringLiteral' }
                }
              }
            }
          }
        )
        expect(rules.query_nodes(node)).to eq [node.body.last.value]

        rules = described_class.new(
          {
            node_type: 'CallNode',
            arguments: {
              arguments: {
                parts: {
                  size: 2,
                  '0': { node_type: 'Int' },
                  '-1': { node_type: 'StringLiteral' }
                }
              }
            }
          }
        )
        expect(rules.query_nodes(node)).to eq [node.body.last.value]
      end

      it 'matches evaluated value' do
        rules = described_class.new({ node_type: 'Assign', target: '@{{value}}' })
        expect(rules.query_nodes(node)).to eq node.body.first.bodystmt.statements.body.first.bodystmt.statements.body
      end

      it 'matches evaluated value from base node' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            name: 'initialize',
            bodystmt: { statements: { body: { '0': { target: "@{{bodystmt.statements.body.0.value}}" } } } }
          }
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.bodystmt.statements.body.first]
      end

      it 'matches empty string' do
        node = syntax_tree_parse("call('')")
        rules = described_class.new(
          {
            node_type: 'CallNode',
            message: :call,
            arguments: { arguments: { parts: { first: '' } } }
          }
        )
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches hash value' do
        node = syntax_tree_parse("{ foo: 'bar' }")
        rules = described_class.new({ node_type: 'HashLiteral', foo_value: 'bar' })
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end
    end
  end
end
