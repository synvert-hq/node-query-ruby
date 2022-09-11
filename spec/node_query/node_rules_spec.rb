require 'spec_helper'

RSpec.describe NodeQuery::NodeRules do
  describe '#query_nodes' do
    let(:node) {
      parse(<<~EOS)
        class Synvert < Base
          def foo
            FactoryBot.create(:user, name: 'foo')
          end

          def bar
            FactoryBot.create(:user, name: 'bar')
          end

          def foobar(a, b)
            { a: a, b: b }
            arr[index]
            arr[index] = value
            nil?
            call('')
          end
        end
      EOS
    }

    let(:test_node) {
      parse(<<~EOS)
        RSpec.describe Synvert do
        end
      EOS
    }

    it 'matches node type' do
      rules = described_class.new({ nodeType: 'def' })
      expect(rules.query_nodes(node)).to eq node.body
    end

    it 'matches node type and one attribute' do
      rules = described_class.new({ nodeType: 'class', name: 'Synvert' })
      expect(rules.query_nodes(node)).to eq [node]
    end

    it 'matches multiple attributes' do
      rules = described_class.new({ nodeType: 'def', arguments: { size: 2, '0': 'a', '1': 'b' } })
      expect(rules.query_nodes(node)).to eq [node.body.last]
    end

    it 'matches nested attribute' do
      rules = described_class.new({ nodeType: 'class', parent_class: { name: 'Base' } })
      expect(rules.query_nodes(node)).to eq [node]
    end

    it 'matches not' do
      rules = described_class.new({ nodeType: 'def', name: { not: 'foobar' } })
      expect(rules.query_nodes(node)).to eq [node.body.first, node.body.second]
    end

    it 'matches regex' do
      rules = described_class.new({ nodeType: 'def', name: /foo/ })
      expect(rules.query_nodes(node)).to eq [node.body.first, node.body.last]
    end

    it 'matches regex not' do
      rules = described_class.new({ nodeType: 'def', name: { not: /bar/ } })
      expect(rules.query_nodes(node)).to eq [node.body.first]
    end

    it 'matches in' do
      rules = described_class.new({ nodeType: 'def', name: { in: ['foo', 'bar'] } })
      expect(rules.query_nodes(node)).to eq [node.body.first, node.body.second]
    end

    it 'matches not_in' do
      rules = described_class.new({ nodeType: 'def', name: { not_in: ['foo', 'bar'] } })
      expect(rules.query_nodes(node)).to eq [node.body.last]
    end

    it 'matches includes' do
      rules = described_class.new({ nodeType: 'def', arguments: { includes: 'a' } })
      expect(rules.query_nodes(node)).to eq [node.body.last]
    end

    it 'matches equal array' do
      rules = described_class.new({ nodeType: 'def', arguments: ['a', 'b'] })
      expect(rules.query_nodes(node)).to eq [node.body.last]

      rules = described_class.new({ nodeType: 'def', arguments: ['b', 'a'] })
      expect(rules.query_nodes(node)).to eq []
    end

    it 'matches not equal array' do
      rules = described_class.new({ nodeType: 'def', arguments: { not: ['a', 'b'] } })
      expect(rules.query_nodes(node)).to eq [node.body.first, node.body.second]

      rules = described_class.new({ nodeType: 'def', arguments: { not: ['b', 'a'] } })
      expect(rules.query_nodes(node)).to eq [node.body.first, node.body.second, node.body.last]
    end

    it 'matches nested selector' do
      rules = described_class.new({ nodeType: 'def', body: { '0': { nodeType: 'send', message: 'create' } } })
      expect(rules.query_nodes(node)).to eq [node.body.first, node.body.second]
    end

    it 'matches gte' do
      rules = described_class.new({ nodeType: 'def', arguments: { size: { gte: 2 } } })
      expect(rules.query_nodes(node)).to eq [node.body.third]
    end

    it 'matches gt' do
      rules = described_class.new({ nodeType: 'def', arguments: { size: { gt: 2 } } })
      expect(rules.query_nodes(node)).to eq []
    end

    it 'matches lte' do
      rules = described_class.new({ nodeType: 'def', arguments: { size: { lte: 2 } } })
      expect(rules.query_nodes(node)).to eq [
        node.body.first,
        node.body.second,
        node.body.third
      ]
    end

    it 'matches lt' do
      rules = described_class.new({ nodeType: 'def', arguments: { size: { lt: 2 } } })
      expect(rules.query_nodes(node)).to eq [
        node.body.first,
        node.body.second
      ]
    end

    it 'matches arguments' do
      rules = described_class.new({ nodeType: 'send', arguments: { size: 2, first: { nodeType: 'sym' }, last: { nodeType: 'hash' } } })
      expect(rules.query_nodes(node)).to eq [node.body.first.body.last, node.body.second.body.last]
    end

    it 'matches evaluated value' do
      rules = described_class.new({ nodeType: 'pair', key: '{{value}}' })
      expect(rules.query_nodes(node)).to eq node.body.last.body.first.children
    end

    it 'matches []' do
      rules = described_class.new({ nodeType: 'send', message: :[] })
      expect(rules.query_nodes(node)).to eq [node.body.last.body.second]
    end

    it 'matches []=' do
      rules = described_class.new({ nodeType: 'send', message: :[]= })
      expect(rules.query_nodes(node)).to eq [node.body.last.body.third]
    end

    it 'matches nil and nil?' do
      rules = described_class.new({ nodeType: 'send', reciever: nil, message: :nil? })
      expect(rules.query_nodes(node)).to eq [node.body.last.body.fourth]
    end

    it 'matches empty string' do
      rules = described_class.new({ nodeType: 'send', message: :call, arguments: { first: '' } })
      expect(rules.query_nodes(node)).to eq [node.body.last.body.last]
    end
  end
end
