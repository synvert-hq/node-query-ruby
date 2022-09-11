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

  describe "nql" do
    it "#query_nodes" do
      query = described_class.new('.class[name=Synvert]')
      expect(query.query_nodes(node)).to eq [node]
    end
  end

  describe "rules" do
    it "#query_nodes" do
      query = described_class.new({ nodeType: 'class', name: 'Synvert' })
      expect(query.query_nodes(node)).to eq [node]
    end
  end
end
