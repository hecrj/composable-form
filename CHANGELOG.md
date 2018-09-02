# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.0.1] - 2018-09-02
### Changed
- Replace mentions of old `(,)` operator in docs with the new `Tuple.pair` equivalent in Elm 0.19.
- Fix example in `Field` documentation.

## [4.0.0] - 2018-08-20
### Added
- `Form.Field.mapValues` to easily change the `value` type of a field
- Elm 0.19 support

### Removed
- `Form.Value.update` and `Form.Value.newest`, these are no longer necessary
  given that Elm 0.19 allows to trigger synchronous renders of the view on some
  events.

## [3.0.1] - 2018-08-08
### Changed
- Fix CHANGELOG release links
- Fix `Value.map` documentation example
- Fix `stylish-elephants` custom renderer to work with `3.0.0`

## [3.0.0] - 2018-08-08
### Added
- `Value.map` to transform value types.
- This CHANGELOG! :tada:

### Changed
- `Field.update` and `Value.update` to allow clearing field values.
- `Form.View.NumberFieldConfig.onChange` and `Form.View.RangeFieldConfig.onChange`
  to allow clearing the values of these fields from view code.
- Add `number` type variable to `Form.Base.NumberField` and `Form.Base.RangeField`
  to make these more flexible and reusable when building custom fields.

## [2.2.3] - 2018-07-23
### Changed
- Replace `InvoiceAddress` with `Website` in documentation.

## [2.2.2] - 2018-07-23
### Changed
- Clarify "type-safe" explanation in README.

## [2.2.1] - 2018-07-23
### Changed
- Replace "form renderer" with "custom view code" in documentation.
- Fix composability example (by @russelldavies).

## [2.2.0] - 2018-07-13
### Added
- `Form.mapValues`
- `Form.Base.mapValues`
- `Form.Base.mapField`
- [`stylish-elephants` renderer example][elephants-renderer-example]

## [2.1.0] - 2018-07-10
### Added
- `Form.map`
- `Form.Base.map`

## [2.0.1] - 2018-07-07
### Changed
- Fix examples link in README to work with Elm package website.

## [2.0.0] - 2018-06-27
### Changed
- Make `Form.Base.FilledForm` type variable order consistent with `Form.Base.Form`.

## [1.0.3] - 2018-06-27
### Changed
- Fix outdated docs and inconsistent type signatures.

## [1.0.2] - 2018-06-26
### Changed
- Fix `Form.View.State` documentation example.

## [1.0.1] - 2018-06-26
### Changed
- Fix documentation details.

## 1.0.0 - 2018-06-26
### Added
- Initial release.

[Unreleased]: https://github.com/hecrj/composable-form/compare/4.0.1...HEAD
[4.0.1]: https://github.com/hecrj/composable-form/compare/4.0.0...4.0.1
[4.0.0]: https://github.com/hecrj/composable-form/compare/3.0.1...4.0.0
[3.0.1]: https://github.com/hecrj/composable-form/compare/3.0.0...3.0.1
[3.0.0]: https://github.com/hecrj/composable-form/compare/2.2.3...3.0.0
[2.2.3]: https://github.com/hecrj/composable-form/compare/2.2.2...2.2.3
[2.2.2]: https://github.com/hecrj/composable-form/compare/2.2.1...2.2.2
[2.2.1]: https://github.com/hecrj/composable-form/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/hecrj/composable-form/compare/2.1.0...2.2.0
[2.1.0]: https://github.com/hecrj/composable-form/compare/2.0.1...2.1.0
[2.0.1]: https://github.com/hecrj/composable-form/compare/2.0.0...2.0.1
[2.0.0]: https://github.com/hecrj/composable-form/compare/1.0.3...2.0.0
[1.0.3]: https://github.com/hecrj/composable-form/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/hecrj/composable-form/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/hecrj/composable-form/compare/1.0.0...1.0.1
[elephants-renderer-example]: https://github.com/hecrj/composable-form/blob/master/examples/src/Form/View/Elements.elm
