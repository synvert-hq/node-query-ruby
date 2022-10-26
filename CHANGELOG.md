# CHANGELOG

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
