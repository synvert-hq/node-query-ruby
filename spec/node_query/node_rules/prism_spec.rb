require 'spec_helper'

RSpec.describe NodeQuery::NodeRules do
  describe '#query_nodes' do
    context 'prism' do
      let(:adapter) { NodeQuery::PrismAdapter.new }
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

      it 'matches node type', focus: true do
        rules = described_class.new({ node_type: 'DefNode' }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches node type and one attribute' do
        rules = described_class.new({ node_type: 'ClassNode', constant_path: 'User' }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches multiple attributes' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            parameters: { requireds: { size: 2, '0': 'id', '1': 'name' } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches nested attribute' do
        rules = described_class.new({ node_type: 'ClassNode', superclass: { name: 'Base' } }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches not' do
        rules = described_class.new({ node_type: 'DefNode', name: { not: 'foobar' } }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches regex' do
        rules = described_class.new({ node_type: 'DefNode', name: /init/ }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches regex not' do
        rules = described_class.new({ node_type: 'DefNode', name: { not: /foobar/ } }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches in' do
        rules = described_class.new(
          { node_type: 'InstanceVariableWriteNode', name: { in: ['@id', '@name'] } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [
          node.body.first.body.body.first.body.body.first,
          node.body.first.body.body.first.body.body.last
        ]
      end

      it 'matches not_in' do
        rules = described_class.new(
          { node_type: 'InstanceVariableWriteNode', name: { not_in: ['@id', '@name'] } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches includes' do
        rules = described_class.new(
          { node_type: 'DefNode', parameters: { requireds: { includes: 'id' } } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches not_includes' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            parameters: { requireds: { not_includes: 'foobar' } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches equal array' do
        rules = described_class.new(
          { node_type: 'DefNode', parameters: { requireds: ['id', 'name'] } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]

        rules = described_class.new(
          { node_type: 'DefNode', parameters: { requireds: ['name', 'id'] } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches not equal array' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            parameters: { requireds: { not: ['id', 'name'] } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []

        rules = described_class.new(
          {
            node_type: 'DefNode',
            parameters: { requireds: { not: ['name', 'id'] } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches nested selector' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            body: { body: { '0': { node_type: 'InstanceVariableWriteNode' } } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches gte' do
        rules = described_class.new(
          { node_type: 'DefNode', parameters: { requireds: { size: { gte: 2 } } } }, adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches gt' do
        rules = described_class.new(
          { node_type: 'DefNode', parameters: { requireds: { size: { ge: 2 } } } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches lte' do
        rules = described_class.new(
          { node_type: 'DefNode', parameters: { requireds: { size: { lte: 2 } } } }, adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches lt' do
        rules = described_class.new(
          { node_type: 'DefNode', parameters: { requireds: { size: { lt: 2 } } } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches arguments' do
        rules = described_class.new(
          {
            node_type: 'CallNode',
            arguments: {
              arguments: {
                size: 2,
                first: { node_type: 'IntegerNode' },
                last: { node_type: 'StringNode' }
              }
            }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.last.value]

        rules = described_class.new(
          {
            node_type: 'CallNode',
            arguments: {
              arguments: {
                size: 2,
                '0': { node_type: 'IntegerNode' },
                '-1': { node_type: 'StringNode' }
              }
            }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.last.value]
      end

      it 'matches evaluated value' do
        rules = described_class.new({ node_type: 'InstanceVariableWriteNode', name: '@{{value}}' }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq node.body.first.body.body.first.body.body
      end

      it 'matches evaluated value from base node' do
        rules = described_class.new(
          {
            node_type: 'DefNode',
            name: 'initialize',
            body: { body: { '0': { name: "@{{body.body.0.value}}" } } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches empty string' do
        node = prism_parse("call('')")
        rules = described_class.new(
          {
            node_type: 'CallNode',
            message: :call,
            arguments: { arguments: { first: '' } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches hash value' do
        node = prism_parse("{ foo: 'bar' }")
        rules = described_class.new({ node_type: 'HashNode', foo_value: 'bar' }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end
    end
  end
end
