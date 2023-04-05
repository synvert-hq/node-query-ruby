require 'spec_helper'

RSpec.describe NodeQuery::NodeRules do
  describe '#query_nodes' do
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

    it 'matches node type' do
      rules = described_class.new({ node_type: 'def' })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches node type and one attribute' do
      rules = described_class.new({ node_type: 'class', name: 'User' })
      expect(rules.query_nodes(node)).to eq [node.body.first]
    end

    it 'matches multiple attributes' do
      rules = described_class.new({ node_type: 'def', arguments: { size: 2, '0': 'id', '1': 'name' } })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches nested attribute' do
      rules = described_class.new({ node_type: 'class', parent_class: { name: 'Base' } })
      expect(rules.query_nodes(node)).to eq [node.body.first]
    end

    it 'matches not' do
      rules = described_class.new({ node_type: 'def', name: { not: 'foobar' } })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches regex' do
      rules = described_class.new({ node_type: 'def', name: /init/ })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches regex not' do
      rules = described_class.new({ node_type: 'def', name: { not: /foobar/ } })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches in' do
      rules = described_class.new({ node_type: 'ivasgn', variable: { in: ['@id', '@name'] } })
      expect(rules.query_nodes(node)).to eq node.body.first.body.first.body
    end

    it 'matches not_in' do
      rules = described_class.new({ node_type: 'ivasgn', variable: { not_in: ['@id', '@name'] } })
      expect(rules.query_nodes(node)).to eq []
    end

    it 'matches includes' do
      rules = described_class.new({ node_type: 'def', arguments: { includes: 'id' } })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches not_includes' do
      rules = described_class.new({ node_type: 'def', arguments: { not_includes: 'foobar' } })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches equal array' do
      rules = described_class.new({ node_type: 'def', arguments: ['id', 'name'] })
      expect(rules.query_nodes(node)).to eq node.body.first.body

      rules = described_class.new({ node_type: 'def', arguments: ['name', 'id'] })
      expect(rules.query_nodes(node)).to eq []
    end

    it 'matches not equal array' do
      rules = described_class.new({ node_type: 'def', arguments: { not: ['id', 'name'] } })
      expect(rules.query_nodes(node)).to eq []

      rules = described_class.new({ node_type: 'def', arguments: { not: ['name', 'id'] } })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches nested selector' do
      rules = described_class.new({ node_type: 'def', body: { '0': { node_type: 'ivasgn' } } })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches gte' do
      rules = described_class.new({ node_type: 'def', arguments: { size: { gte: 2 } } })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches gt' do
      rules = described_class.new({ node_type: 'def', arguments: { size: { gt: 2 } } })
      expect(rules.query_nodes(node)).to eq []
    end

    it 'matches lte' do
      rules = described_class.new({ node_type: 'def', arguments: { size: { lte: 2 } } })
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches lt' do
      rules = described_class.new({ node_type: 'def', arguments: { size: { lt: 2 } } })
      expect(rules.query_nodes(node)).to eq []
    end

    it 'matches arguments' do
      rules = described_class.new(
        {
          node_type: 'send',
          arguments: { size: 2, first: { node_type: 'int' }, last: { node_type: 'str' } }
        }
      )
      expect(rules.query_nodes(node)).to eq [node.body.last.value]

      rules = described_class.new(
        {
          node_type: 'send',
          arguments: { size: 2, '0': { node_type: 'int' }, '-1': { node_type: 'str' } }
        }
      )
      expect(rules.query_nodes(node)).to eq [node.body.last.value]
    end

    it 'matches evaluated value' do
      rules = described_class.new({ node_type: 'ivasgn', variable: '@{{value}}' })
      expect(rules.query_nodes(node)).to eq node.body.first.body.first.body
    end

    it 'matches evaluated value from base node' do
      rules = described_class.new(
        {
          node_type: 'def',
          name: 'initialize',
          body: { '0': { variable: "@{{body.0.value}}" } }
        }
      )
      expect(rules.query_nodes(node)).to eq node.body.first.body
    end

    it 'matches []' do
      node = parse("user[:error]")
      rules = described_class.new({ node_type: 'send', message: :[] })
      expect(rules.query_nodes(node)).to eq [node]
    end

    it 'matches []=' do
      node = parse("user[:error] = 'error'")
      rules = described_class.new({ node_type: 'send', message: :[]= })
      expect(rules.query_nodes(node)).to eq [node]
    end

    it 'matches nil and nil?' do
      node = parse("nil.nil?")
      rules = described_class.new({ node_type: 'send', reciever: nil, message: :nil? })
      expect(rules.query_nodes(node)).to eq [node]
    end

    it 'matches empty string' do
      node = parse("call('')")
      rules = described_class.new({ node_type: 'send', message: :call, arguments: { first: '' } })
      expect(rules.query_nodes(node)).to eq [node]
    end

    it 'matches hash value' do
      node = parse("{ foo: 'bar' }")
      rules = described_class.new({ node_type: 'hash', foo_value: 'bar' })
      expect(rules.query_nodes(node)).to eq [node]
    end

    it 'raises error' do
      node = parse("Foobar.stub :new, &block")
      rules = described_class.new(
        {
          node_type: 'send',
          message: 'stub',
          arguments: [{ type: 'sym' }, { type: 'block_pass' }]
        }
      )
      expect {
        rules.query_nodes(node)
      }.to raise_error(NodeQuery::MethodNotSupported, '{:type=>"sym"} is not supported')
    end

    it 'sets option including_self to false' do
      rules = described_class.new({ node_type: 'class' })
      expect(rules.query_nodes(node.children.first, { including_self: false })).to eq []

      expect(rules.query_nodes(node.children.first)).to eq [node.children.first]
    end

    it 'sets options stop_at_first_match to true' do
      rules = described_class.new({ node_type: 'ivasgn' })
      expect(
        rules.query_nodes(
          node.children.first,
          { stop_at_first_match: true }
        )
      ).to eq [node.children.first.body.first.body.first]

      # expect(rules.query_nodes(node.children.first)).to eq node.children.first.body.first.body
    end

    it 'sets options recursive to false' do
      rules = described_class.new({ node_type: 'def' })
      expect(rules.query_nodes(node, { recursive: false })).to eq []

      expect(rules.query_nodes(node)).to eq [node.children.first.body.first]
    end
  end
end
