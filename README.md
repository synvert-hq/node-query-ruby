# NodeQuery

NodeQuery defines a NQL (node query language) and node rules to query AST nodes.

## Table of Contents

- [NodeQuery](#nodequery)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Node Query Language](#node-query-language)
    - [nql matches node type](#nql-matches-node-type)
    - [nql matches attribute](#nql-matches-attribute)
    - [nql matches nested attribute](#nql-matches-nested-attribute)
    - [nql matches evaluated value](#nql-matches-evaluated-value)
    - [nql matches nested selector](#nql-matches-nested-selector)
    - [nql matches method result](#nql-matches-method-result)
    - [nql matches operators](#nql-matches-operators)
    - [nql matches array node attribute](#nql-matches-array-node-attribute)
    - [nql matches * in attribute key](#nql-matches--in-attribute-key)
    - [nql matches multiple selectors](#nql-matches-multiple-selectors)
      - [Descendant combinator](#descendant-combinator)
      - [Child combinator](#child-combinator)
      - [Adjacent sibling combinator](#adjacent-sibling-combinator)
      - [General sibling combinator](#general-sibling-combinator)
    - [nql matches goto scope](#nql-matches-goto-scope)
    - [nql matches pseudo selector](#nql-matches-pseudo-selector)
    - [nql matches multiple expressions](#nql-matches-multiple-expressions)
  - [Node Rules](#node-rules)
    - [rules matches node type](#rules-matches-node-type)
    - [rules matches attribute](#rules-matches-attribute)
    - [rules matches nested attribute](#rules-matches-nested-attribute)
    - [rules matches evaluated value](#rules-matches-evaluated-value)
    - [rules matches nested selector](#rules-matches-nested-selector)
    - [rules matches method result](#rules-matches-method-result)
    - [rules matches operators](#rules-matches-operators)
    - [rules matches array nodes attribute](#rules-matches-array-nodes-attribute)
  - [Write Adapter](#write-adapter)
  - [Development](#development)
  - [Contributing](#contributing)

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

It provides two apis: `query_nodes` and `match_node?`

```ruby
node_query = NodeQuery.new(nql_or_rules: String | Hash) # Initialize NodeQuery
node_query.query_nodes(node: Node, options = { including_self: true, stop_at_first_match: false, recursive: true }): Node[] # Get the matching nodes.
node_query.match_node?(node: Node): boolean # Check if the node matches nql or rules.
```

Here is an example for parser ast node.

```ruby
source = `
  class User
    def initialize(id, name)
      @id = id
      @name = name
    end
  end

  user = User.new(1, "Murphy")
`
node = Parser::CurrentRuby.parse(source)

# It will get the node of initialize.
NodeQuery.new('.def[name=initialize]').query_nodes(node)
NodeQuery.new({ node_type: 'def', name: 'initialize' }).query_nodes(node)
```

## Node Query Language

### nql matches node type

```
.class
```

It matches class node

### nql matches attribute

```
.class[name=User]
```

It matches class node whose name is User

### nql matches nested attribute

```
.class[parent_class.name=Base]
```

It matches class node whose parent class name is Base

### nql matches evaluated value

```
.ivasgn[left_value="@{{right_value}}"]
```

It matches ivasgn node whose left value equals '@' plus the evaluated value of right value.

### nql matches nested selector

```
.def[body.0=.ivasgn]
```

It matches def node whose first child node is an ivasgn node.

### nql matches method result

```
.def[arguments.size=2]
```

It matches def node whose arguments size is 2.

### nql matches operators

```
.class[name=User]
```

Value of name is equal to User

```
.class[name^=User]
```

Value of name starts with User

```
.class[name$=User]
```

Value of name ends with User

```
.class[name*=User]
```

Value of name contains User

```
.def[arguments.size!=2]
```

Size of arguments is not equal to 2

```
.def[arguments.size>=2]
```

Size of arguments is greater than or equal to 2

```
.def[arguments.size>2]
```

Size of arguments is greater than 2

```
.def[arguments.size<=2]
```

Size of arguments is less than or equal to 2

```
.def[arguments.size<2]
```

Size of arguments is less than 2

```
.class[name IN (User Account)]
```

Value of name is either User or Account

```
.class[name NOT IN (User Account)]
```

Value of name is neither User nor Account

```
.def[arguments INCLUDES id]
```

Value of arguments includes id

```
.class[name=~/User/]
```

Value of name matches User

```
.class[name!~/User/]
```

Value of name does not match User

```
.class[name IN (/User/ /Account/)]
```

Value of name matches either /User/ or /Account/

### nql matches array node attribute

```
.def[arguments=(id name)]
```

It matches def node whose arguments are id and name.

### nql matches * in attribute key

```
.def[arguments.*.name IN (id name)]
```

It matches def node whose arguments are either id or name.

### nql matches multiple selectors

#### Descendant combinator

```
.class .send
```

It matches send node whose ansestor is class node.

#### Child combinator

```
.def > .send
```

It matches send node whose parent is def node.

#### Adjacent sibling combinator

```
.send[left_value=@id] + .send
```

It matches send node only if it is immediately follows the send node whose left value is @id.

#### General sibling combinator

```
.send[left_value=@id] ~ .send
```

It matches send node only if it is follows the send node whose left value is @id.

### nql matches goto scope

```
.def body .send
```

It matches send node who is in the body of def node.

### nql matches pseudo selector

```
.class:has(.def[name=initialize])
```

It matches class node who has an initialize def node.

```
.class:not_has(.def[name=initialize])
```

It matches class node who does not have an initialize def node.

### nql matches multiple expressions

```
.ivasgn[left_value=@id], .ivasgn[left_value=@name]
```

It matches ivasgn node whose left value is either @id or @name.

## Node Rules

### rules matches node type

```
{ node_type: 'class' }
```

It matches class node

### rules matches attribute

```
{ node_type: 'def', name: 'initialize' }
```

It matches def node whose name is initialize

```
{ node_type: 'def', arguments: { "0": 1, "1": "Murphy" } }
```

It matches def node whose arguments are 1 and Murphy.

### rules matches nested attribute

```
{ node_type: 'class', parent_class: { name: 'Base' } }
```

It matches class node whose parent class name is Base

### rules matches evaluated value

```
{ node_type: 'ivasgn', left_value: '@{{right_value}}' }
```

It matches ivasgn node whose left value equals '@' plus the evaluated value of right value.

### rules matches nested selector

```
{ node_type: 'def', body: { "0": { node_type: 'ivasgn' } } }
```

It matches def node whose first child node is an ivasgn node.

### rules matches method result

```
{ node_type: 'def', arguments: { size: 2 } }
```

It matches def node whose arguments size is 2.

### rules matches operators

```
{ node_type: 'class', name: 'User' }
```

Value of name is equal to User

```
{ node_type: 'def', arguments: { size { not: 2 } }
```

Size of arguments is not equal to 2

```
{ node_type: 'def', arguments: { size { gte: 2 } }
```

Size of arguments is greater than or equal to 2

```
{ node_type: 'def', arguments: { size { gt: 2 } }
```

Size of arguments is greater than 2

```
{ node_type: 'def', arguments: { size { lte: 2 } }
```

Size of arguments is less than or equal to 2

```
{ node_type: 'def', arguments: { size { lt: 2 } }
```

Size of arguments is less than 2

```
{ node_type: 'class', name: { in: ['User', 'Account'] } }
```

Value of name is either User or Account

```
{ node_type: 'class', name: { not_in: ['User', 'Account'] } }
```

Value of name is neither User nor Account

```
{ node_type: 'def', arguments: { includes: 'id' } }
```

Value of arguments includes id

```
{ node_type: 'class', name: /User/ }
```

Value of name matches User

```
{ node_type: 'class', name: { not: /User/ } }
```

Value of name does not match User

```
{ node_type: 'class', name: { in: [/User/, /Account/] } }
```

Value of name matches either /User/ or /Account/

### rules matches array nodes attribute

```
{ node_type: 'def', arguments: ['id', 'name'] }
```

It matches def node whose arguments are id and name.

## Write Adapter

Different parser, like parser, will generate different AST nodes, to make NodeQuery work for them all,
we define an [Adapter](https://github.com/xinminlabs/node-query-ruby/blob/main/lib/node_query/adapter.rb) interface,
if you implement the Adapter interface, you can set it as NodeQuery's adapter.

```ruby
NodeQuery.configure(adapter: ParserAdapter.new)
```

Here is the ParserAdapter implementation:

[ParserAdapter](https://github.com/xinminlabs/node-query-ruby/blob/main/lib/node_query/parser_adapter.rb)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xinminlabs/node-query-ruby.
