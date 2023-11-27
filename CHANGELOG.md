# CHANGELOG

## 1.14.0 (2023-11-27)

* Add `adapter` parameter to `NodeQuery`
* Do not allow to configure an `adapter` globally

## 1.13.12 (2023-09-29)

* `NODE_TYPE` can contain `_`
* Update `syntax_tree_ext` to 0.6.4

## 1.13.11 (2023-08-17)

* Do not handle if `child_node` is nil

## 1.13.10 (2023-08-12)

* Update `node_query_parser.y`

## 1.13.9 (2023-08-02)

* Add `OPERATOR` macro
* Use operator `=` instead of `==`

## 1.13.8 (2023-06-28)

* Check `.to_value` instead of `.type`

## 1.13.7 (2023-06-26)

* Revert "Flatten syntax_tree children"

## 1.13.6 (2023-06-26)

* Flatten syntax_tree children

## 1.13.5 (2023-06-17)

* Separate syntax_tree tests from parser tests
* Flatten child iteration for syntax_tree

## 1.13.4 (2023-06-15)

* Support `Hash#except` for ruby 2

## 1.13.3 (2023-06-14)

* Use `deconstruct_key` to get syntax_tree node children
* `handle_recursive_child` handles Array child node

## 1.13.2 (2023-05-18)

* Replace `Parser` specific code

## 1.13.1 (2023-05-16)

* Require `parser` and `syntax_tree` in adapter
* `SyntaxTreeParser#get_node_type` returns a symbol
* Node type can be upcase

## 1.13.0 (2023-05-15)

* Add `SyntaxTreeParser`

## 1.12.1 (2023-04-06)

* Fix when `actual` is nil

## 1.12.0 (2023-01-16)

* Drop `activesupport`
* Remove `NodeQuery::AnyValue`

## 1.11.0 (2022-12-09)

* Support negative index to fetch array element
* Parse negative integer and float

## 1.10.0 (2022-10-26)

* Add `NodeQuery::MethodNotSupported` error
* Add `NodeQuery::AnyValue` to match any value in node rules

## 1.9.0 (2022-10-23)

* Support `NOT INCLUDES` operator
* `includes` / `not_includes` a selector

## 1.8.1 (2022-10-15)

* Fix `filter_by_position` with empty nodes

## 1.8.0 (2022-10-14)

* Support `:first-child` and `:last-child`

## 1.7.0 (2022-10-01)

* Better regexp to match evaluated value
* Make `base_node` as the root matching node

## 1.6.1 (2022-09-28)

* Do not handle `erange` and `irange` in `actual_value`

## 1.6.0 (2022-09-16)

* Rename `nodeType` to `node_type`

## 1.5.0 (2022-09-15)

* Add `Helper.to_string`
* Only check the current node if `including_self` is true and `recursive` is false
* Fix `Regexp#match?` and `String#match?`
* Rename `stop_on_match` to `stop_at_first_match`

## 1.4.0 (2022-09-14)

* Add options `including_self`, `stop_on_match` and `recursive`
* Fix regex to match evaluated value

## 1.3.0 (2022-09-13)

* Rename `NodeQuery#parse` to `NodeQuery#query_nodes`
* `NodeQuery#query_ndoes` accepts `including_self` argument
* `NodeQuery#query_ndoes` supports both nql and rules
* Add `NodeQuery#match_node?`
* Add `NdoeRules`
* Drop `EvaluatedValue`, use `String` instead
* Write better test cases

## 1.2.0 (2022-07-01)

* Rename `NodeQuery.get_adapter` to `NodeQuery.adapter`
* Use generic type in rbs
* Fix `Compiler::Array` to `Compiler::ArrayValue`

## 1.1.0 (2022-06-27)

* Support `*` in attribute key
* Add new Adapter method `is_node?`

## 1.0.0 (2022-06-26)

* Abstract from synvert-core
