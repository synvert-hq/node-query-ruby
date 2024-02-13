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
        rules = described_class.new({ node_type: 'def_node' }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches node type and one attribute' do
        rules = described_class.new({ node_type: 'class_node', constant_path: 'User' }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches multiple attributes' do
        rules = described_class.new(
          {
            node_type: 'def_node',
            parameters: { requireds: { size: 2, '0': 'id', '1': 'name' } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches nested attribute' do
        rules = described_class.new({ node_type: 'class_node', superclass: { name: 'Base' } }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches not' do
        rules = described_class.new({ node_type: 'def_node', name: { not: 'foobar' } }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches regex' do
        rules = described_class.new({ node_type: 'def_node', name: /init/ }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches regex not' do
        rules = described_class.new({ node_type: 'def_node', name: { not: /foobar/ } }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches in' do
        rules = described_class.new(
          { node_type: 'instance_variable_write_node', name: { in: ['@id', '@name'] } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [
          node.body.first.body.body.first.body.body.first,
          node.body.first.body.body.first.body.body.last
        ]
      end

      it 'matches not_in' do
        rules = described_class.new(
          { node_type: 'instance_variable_write_node', name: { not_in: ['@id', '@name'] } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches includes' do
        rules = described_class.new(
          { node_type: 'def_node', parameters: { requireds: { includes: 'id' } } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches not_includes' do
        rules = described_class.new(
          {
            node_type: 'def_node',
            parameters: { requireds: { not_includes: 'foobar' } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches equal array' do
        rules = described_class.new(
          { node_type: 'def_node', parameters: { requireds: ['id', 'name'] } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]

        rules = described_class.new(
          { node_type: 'def_node', parameters: { requireds: ['name', 'id'] } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches not equal array' do
        rules = described_class.new(
          {
            node_type: 'def_node',
            parameters: { requireds: { not: ['id', 'name'] } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []

        rules = described_class.new(
          {
            node_type: 'def_node',
            parameters: { requireds: { not: ['name', 'id'] } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches nested selector' do
        rules = described_class.new(
          {
            node_type: 'def_node',
            body: { body: { '0': { node_type: 'instance_variable_write_node' } } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches gte' do
        rules = described_class.new(
          { node_type: 'def_node', parameters: { requireds: { size: { gte: 2 } } } }, adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches gt' do
        rules = described_class.new(
          { node_type: 'def_node', parameters: { requireds: { size: { ge: 2 } } } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches lte' do
        rules = described_class.new(
          { node_type: 'def_node', parameters: { requireds: { size: { lte: 2 } } } }, adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first.body.body.first]
      end

      it 'matches lt' do
        rules = described_class.new(
          { node_type: 'def_node', parameters: { requireds: { size: { lt: 2 } } } },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq []
      end

      it 'matches arguments' do
        rules = described_class.new(
          {
            node_type: 'call_node',
            arguments: {
              arguments: {
                size: 2,
                first: { node_type: 'integer_node' },
                last: { node_type: 'string_node' }
              }
            }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.last.value]

        rules = described_class.new(
          {
            node_type: 'call_node',
            arguments: {
              arguments: {
                size: 2,
                '0': { node_type: 'integer_node' },
                '-1': { node_type: 'string_node' }
              }
            }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.last.value]
      end

      it 'matches evaluated value' do
        rules = described_class.new({ node_type: 'instance_variable_write_node', name: '@{{value}}' }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq node.body.first.body.body.first.body.body
      end

      it 'matches evaluated value from base node' do
        rules = described_class.new(
          {
            node_type: 'def_node',
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
            node_type: 'call_node',
            message: :call,
            arguments: { arguments: { first: '' } }
          },
          adapter: adapter
        )
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end

      it 'matches hash value' do
        node = prism_parse("{ foo: 'bar' }")
        rules = described_class.new({ node_type: 'hash_node', foo_value: 'bar' }, adapter: adapter)
        expect(rules.query_nodes(node)).to eq [node.body.first]
      end
    end
  end
end
