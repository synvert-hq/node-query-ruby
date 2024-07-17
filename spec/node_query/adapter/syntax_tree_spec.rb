# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NodeQuery::SyntaxTreeAdapter do
  let(:adapter) { described_class.new }

  describe "#is_node?" do
    it 'gets true for node' do
      node = syntax_tree_parse("class Synvert; end").body.first
      expect(adapter.is_node?(node)).to be_truthy
    end

    it 'gets false for other' do
      expect(adapter.is_node?("Synvert")).to be_falsey
    end
  end

  describe "#get_node_type" do
    it "gets the type of node" do
      node = syntax_tree_parse("class Synvert; end").body.first
      expect(adapter.get_node_type(node)).to eq :ClassDeclaration
    end
  end

  describe "#get_source" do
    it "gets the source code of node" do
      code = "class Synvert; end"
      node = syntax_tree_parse(code).body.first
      expect(adapter.get_source(node)).to eq code
    end
  end

  describe "#get_children" do
    it "gets the children of node" do
      node = syntax_tree_parse("class Synvert; end").body.first
      child_nodes = adapter.get_children(node)
      expect(child_nodes.size).to eq 3
      expect(child_nodes[0].class).to eq SyntaxTree::ConstRef
      expect(child_nodes[1]).to be_nil
      expect(child_nodes[2].class).to eq SyntaxTree::BodyStmt
    end
  end

  describe "#get_siblings" do
    it "gets the siblings of node" do
      node = syntax_tree_parse("class Synvert; end").body.first.constant
      siblings = adapter.get_siblings(node)
      expect(siblings.size).to eq 2
      expect(siblings[0]).to be_nil
      expect(siblings[1].class).to eq SyntaxTree::BodyStmt
    end
  end
end
