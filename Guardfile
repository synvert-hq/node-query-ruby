# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('lib/node_query_lexer.rex.rb') { 'spec/node_query_lexer_spec.rb'  }
  watch('lib/node_query_compiler.rb') { 'spec/node_query_parser_spec.rb'  }
  watch(%r{^lib/node_query/compiler/.*\.rb$}) { 'spec/node_query_parser_spec.rb' }
  watch('lib/node_query/parser.racc.rb') { 'spec/node_query_parser_spec.rb' }
  watch('spec/spec_helper.rb') { "spec" }
end

guard :rake, task: 'generate' do
  watch('lib/node_query_lexer.rex')
  watch('lib/node_query_parser.y')
end
