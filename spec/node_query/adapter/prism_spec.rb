# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NodeQuery::PrismAdapter do
  let(:adapter) { described_class.new }

  describe "#is_node?" do
    it 'gets true for node' do
      node = prism_parse("class Synvert; end").body.first
      expect(adapter.is_node?(node)).to be_truthy
    end

    it 'gets false for other' do
      expect(adapter.is_node?("Synvert")).to be_falsey
    end
  end

  describe "#get_node_type" do
    it "gets the type of node" do
      node = prism_parse("class Synvert; end").body.first
      expect(adapter.get_node_type(node)).to eq :class_node
    end
  end

  describe "#get_source" do
    it "gets the source code of node" do
      code = "class Synvert; end"
      node = prism_parse(code).body.first
      expect(adapter.get_source(node)).to eq code
    end
  end

  describe "#get_children" do
    it "gets the children of node" do
      node = prism_parse("class Synvert; end").body.first
      child_nodes = adapter.get_children(node)
      expect(child_nodes.size).to eq 8
      expect(child_nodes[1]).to eq 'class'
      expect(child_nodes[2].class).to eq Prism::ConstantReadNode
      expect(child_nodes[2].name).to eq :Synvert
      expect(child_nodes[7]).to eq :Synvert
    end
  end

  if ENV['TEST_SIBLINGS'] == 'true'
    require 'prism_ext/parent_node_ext'

    describe "#get_siblings" do
      it "gets the siblings of node" do
        node = prism_parse("class Synvert; end").body.first.constant_path
        siblings = adapter.get_siblings(node)
        expect(siblings.size).to eq 5
        expect(siblings[0]).to be_nil
        expect(siblings[1]).to be_nil
        expect(siblings[4]).to eq :Synvert
      end
    end
  end
end
