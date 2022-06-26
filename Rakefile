# frozen_string_literal: true

require "bundler/gem_tasks"
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
require 'oedipus_lex'
Rake.application.rake_require "oedipus_lex"

file "lib/lexer.rex.rb" => "lib/lexer.rex"
file "lib/parser.racc.rb" => "lib/parser.y"

task :lexer  => "lib/lexer.rex.rb"
task :parser => "lib/parser.racc.rb"
task :generate  => [:lexer, :parser]

rule '.racc.rb' => '.y' do |t|
  cmd = "bundle exec racc -l -v -o #{t.name} #{t.source}"
  sh cmd
end

task :default => :spec
task :spec => :generate
