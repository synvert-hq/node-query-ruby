# frozen_string_literal: true

require 'spec_helper'

RSpec.describe NodeQuery::Helper do
  describe '.get_target_node' do
    it 'checks node_type' do
      node = parse('Factory.define :user do |user|; end')
      child_node = described_class.get_target_node(node, 'node_type')
      expect(child_node).to eq :block
    end

    context 'block node' do
      it 'checks caller' do
        node = parse('Factory.define :user do |user|; end')
        child_node = described_class.get_target_node(node, 'caller')
        expect(child_node).to eq node.caller
      end

      it 'checks arguments' do
        node = parse('Factory.define :user do |user|; end')
        child_node = described_class.get_target_node(node, 'arguments')
        expect(child_node).to eq node.arguments
      end

      it 'checks caller.receiver' do
        node = parse('Factory.define :user do |user|; end')
        child_node = described_class.get_target_node(node, 'caller.receiver')
        expect(child_node).to eq node.caller.receiver
      end

      it 'checks caller.message' do
        node = parse('Factory.define :user do |user|; end')
        child_node = described_class.get_target_node(node, 'caller.message')
        expect(child_node).to eq node.caller.message
      end
    end

    context 'array' do
      it 'checks array by index' do
        node = parse('factory :admin, class: User do; end')
        child_node = described_class.get_target_node(node, 'caller.arguments.1')
        expect(child_node).to eq node.caller.arguments[1]
      end

      it 'checks array by method' do
        node = parse('factory :admin, class: User do; end')
        child_node = described_class.get_target_node(node, 'caller.arguments.first')
        expect(child_node).to eq node.caller.arguments.first
      end
    end
  end

  describe '.handle_recursive_child' do
    it 'recursively handle all children' do
      node = parse('class Synvert; def current_node; @node; end; end')
      children = []
      described_class.handle_recursive_child(node) { |child| children << child.type }
      expect(children).to be_include :const
      expect(children).to be_include :def
      expect(children).to be_include :args
      expect(children).to be_include :ivar
    end
  end

  describe '.evaluate_node_value' do
    it 'returns an evaluated string' do
      node = parse('@id = id')
      value = described_class.evaluate_node_value(node, "@{{value}}")
      expect(value).to eq '@id'
    end
  end

  describe '.to_string' do
    it 'gets source code of the node' do
      node = parse('@id = id')
      expect(described_class.to_string(node)).to eq '@id = id'
    end

    it 'gets string' do
      expect(described_class.to_string(true)).to eq 'true'
    end
  end
end
