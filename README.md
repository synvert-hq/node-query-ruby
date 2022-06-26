# NodeQuery

NodeQuery defines an AST node query language, which is a css like syntax for matching nodes.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'node_query'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install node_query

## Usage

It provides only one api:

```ruby
NodeQuery.new(nodeQueryString).parse(node)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xinminlabs/node-query-ruby.
