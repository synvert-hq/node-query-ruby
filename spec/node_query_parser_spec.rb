require 'spec_helper'
require 'oedipus_lex'

RSpec.describe NodeQueryParser do
  let(:parser) { described_class.new(adapter: :parser) }

  describe '#toString' do
    it 'parses node ype' do
      source = '.send'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses one selector' do
      source = '.send[message=:create]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses two selectors' do
      source = '.class[name=Synvert] .def[name="foobar"]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses three selectors' do
      source = '.class[name=Synvert] .def[name="foobar"] .send[message=create]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses child selector' do
      source = '.class[name=Synvert] > .def[name="foobar"]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :has pseduo class selector' do
      source = '.class :has(> .def)'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :not_has pseduo class selector' do
      source = '.class :not_has(> .def)'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses multiple attributes' do
      source = '.send[receiver=nil][message=:create]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses nested selector' do
      source = '.def[body.0=.send[message=create]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses selector value' do
      source = '.send[receiver=.send[message=:create]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses ^= operator' do
      source = '.def[name^=synvert]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses $= operator' do
      source = '.def[name$=synvert]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses *= operator' do
      source = '.def[name*=synvert]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses != operator' do
      source = '.send[receiver=.send[message!=:create]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses > operator' do
      source = '.send[receiver=.send[arguments.size>1]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses >= operator' do
      source = '.send[receiver=.send[arguments.size>=1]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses < operator' do
      source = '.send[receiver=.send[arguments.size<1]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses <= operator' do
      source = '.send[receiver=.send[arguments.size<=1]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses in operator' do
      source = '.def[name in (foo bar)]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses not in operator' do
      source = '.def[name not in (foo bar)]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses includes operator' do
      source = '.def[arguments includes &block]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses not includes operator' do
      source = '.def[arguments not includes &block]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses empty string' do
      source = '.send[arguments.first=""]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses []=' do
      source = '.send[message=[]=]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :[]' do
      source = '.send[message=:[]]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses goto scope' do
      source = '.block body > .send'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses * in key' do
      source = '.def[arguments.*.name in (foo bar)]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses ,' do
      source = '.send[message=foo], .send[message=bar]'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :first-child' do
      source = '.send[message=foo]:first-child'
      expect(parser.parse(source).to_s).to eq source
    end

    it 'parses :last-child' do
      source = '.send[message=foo]:last-child'
      expect(parser.parse(source).to_s).to eq source
    end
  end
end
