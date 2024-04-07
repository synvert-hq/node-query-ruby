# frozen_string_literal: true

require_relative "lib/node_query/version"

Gem::Specification.new do |spec|
  spec.name = "node_query"
  spec.version = NodeQuery::VERSION
  spec.authors = ["Richard Huang"]
  spec.email = ["flyerhzm@gmail.com"]

  spec.summary = "ast node query language"
  spec.description = "ast node query language"
  spec.homepage = "https://github.com/synvert-hq/node-query-ruby"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/synvert-hq/node-query-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/synvert-hq/node-query-ruby/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end + %w[lib/node_query_lexer.rex.rb lib/node_query_parser.racc.rb]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
