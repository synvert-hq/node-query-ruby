# frozen_string_literal: true

RSpec.describe NodeQuery do
  let(:node) {
    parse(<<~EOS)
      class Synvert
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

  describe "#query_nodes" do
    it "matches nql" do
      query = described_class.new('.class[name=Synvert]', adapter: :parser)
      expect(query.query_nodes(node)).to eq [node]
    end

    it "matches rules" do
      query = described_class.new({ node_type: 'class', name: 'Synvert' }, adapter: :parser)
      expect(query.query_nodes(node)).to eq [node]
    end
  end

  describe "#match_node?" do
    it "matches nql" do
      query = described_class.new('.class[name=Synvert]', adapter: :parser)
      expect(query.match_node?(node)).to be_truthy
    end

    it "matches rules" do
      query = described_class.new({ node_type: 'class', name: 'Synvert' }, adapter: :parser)
      expect(query.match_node?(node)).to be_truthy
    end
  end
end
