# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('lib/node/query/lexer.rex.rb') { 'spec/node/query/lexer_spec.rb'  }
  watch('lib/node/query/compiler.rb') { 'spec/node/query/parser_spec.rb'  }
  watch(%r{^lib/node/query/compiler/.*\.rb$}) { 'spec/node/query/parser_spec.rb' }
  watch('lib/node/query/parser.racc.rb') { 'spec/node/query/parser_spec.rb' }
  watch('spec/spec_helper.rb') { "spec" }
end

guard :rake, task: 'generate' do
  watch('lib/node/query/lexer.rex')
  watch('lib/node/query/parser.y')
end
