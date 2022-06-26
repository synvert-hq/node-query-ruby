# frozen_string_literal: true

require "node_query"

Dir[File.join(File.dirname(__FILE__), 'support', '*')].each do |path|
  require path
end

RSpec.configure do |config|
  config.include ParserHelper

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
