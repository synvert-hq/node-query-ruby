# CHANGELOG

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
