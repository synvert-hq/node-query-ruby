# frozen_string_literal: true

require "bundler/gem_tasks"
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
require 'oedipus_lex'
Rake.application.rake_require "oedipus_lex"

file "lib/node_query_lexer.rex.rb" => "lib/node_query_lexer.rex"
file "lib/node_query_parser.racc.rb" => "lib/node_query_parser.y"

task :lexer  => "lib/node_query_lexer.rex.rb"
task :parser => "lib/node_query_parser.racc.rb"
task :generate  => [:lexer, :parser]

rule '.racc.rb' => '.y' do |t|
  cmd = "bundle exec racc -l -v -o #{t.name} #{t.source}"
  sh cmd
end

task :default => :spec
task :spec => :generate
