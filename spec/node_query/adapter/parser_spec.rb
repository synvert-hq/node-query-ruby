# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NodeQuery::ParserAdapter do
  let(:adapter) { described_class.new }

  describe "#is_node?" do
    it 'gets true for node' do
      node = parse("class Synvert; end")
      expect(adapter.is_node?(node)).to be_truthy
    end

    it 'gets false for other' do
      expect(adapter.is_node?("Synvert")).to be_falsey
    end
  end

  describe "#get_node_type" do
    it "gets the type of node" do
      node = parse("class Synvert; end")
      expect(adapter.get_node_type(node)).to eq :class
    end
  end

  describe "#get_source" do
    it "gets the source code of node" do
      code = "class Synvert; end"
      node = parse(code)
      expect(adapter.get_source(node)).to eq code
    end
  end

  describe "#get_children" do
    it "gets the children of node" do
      node = parse("class Synvert; end")
      expect(adapter.get_children(node)).to eq [parse("Synvert"), nil, nil]
    end
  end

  describe "#get_siblings" do
    it "gets the siblings of node" do
      node = parse("class Synvert; end").children.first
      expect(adapter.get_siblings(node)).to eq [nil, nil]
    end
  end
end
