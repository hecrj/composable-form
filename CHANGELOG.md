# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [8.0.0] - 2019-07-12
### Added
- `Success` variant to `Form.View.State`. By default, it can be styled using the
  `.elm-form-success` CSS selector. [#26]
- `Form.disable` and `Form.Base.disable`, which allow disabling the fields of a
  form. [#27]

### Changed
- `Form.Base.FilledField` has been renamed to `Form.Base.CustomField` and its
  `field` property has been renamed to `state`. [#27]
- The tuple `( field, Maybe Error )` is replaced with the new record
  `Form.Base.FilledField` everywhere. [#27]
- An `error : values -> Maybe String` attribute was added to field configuration.
  Useful to show server-side validation errors. [#29]
- The `Error` type was extended with an `External` variant. It is meant to
  represent an external error not caused by client-side validation. [#29]
- `NumberField` value storage has been changed from `Maybe Float` to `String` to
  fix issues entering values after the decimal point. [#25] & [#30]
- The `step` item in the `Form.Base.NumberField.Attributes` record has been changed
  from `number` to `Maybe number` to allow a step attribute of `"any"`. [#30]

### Fixed
- Default select field in `Form.View` now listens to the `change` event instead
  of `input`. Internet Explorer and Edge now should work properly with this
  field. [#28]

[#25]: https://github.com/hecrj/composable-form/issues/25
[#26]: https://github.com/hecrj/composable-form/pull/26
[#27]: https://github.com/hecrj/composable-form/pull/27
[#28]: https://github.com/hecrj/composable-form/pull/28
[#29]: https://github.com/hecrj/composable-form/pull/29
[#30]: https://github.com/hecrj/composable-form/pull/30

## [7.1.0] - 2019-05-07
### Added
- `Form.View.htmlViewConfig`, which allows easy customization of the default
  `Form.View.asHtml` function. [#23]

[#23]: https://github.com/hecrj/composable-form/pull/23

## [7.0.2] - 2019-05-04
### Fixed
- Textarea not updating its value properly when using `Form.View.asHtml`. [#21]

[#21]: https://github.com/hecrj/composable-form/issues/21

## [7.0.1] - 2019-04-06
### Changed
- Stop asking users to copy-paste code in the `Form.Base` docs.

## [7.0.0] - 2019-01-25
### Added
- `Form.list` and `Form.Base.FormList` that allow to build a variable list of forms.
  Thanks to everyone involved in #7!

### Changed
- Improved introduction to the `Form` type.

## [6.0.1] - 2018-11-24
### Changed
- Fix radio fields being rendered inside a main label when using `Form.View.asHtml`.
- Remove `fieldset` parent when rendering radio fields using `Form.View.asHtml`.

## [6.0.0] - 2018-11-19
### Added
- `Form.section` (thanks to @russelldavies).
- Ellie snippet on `README`.

### Changed
- Fix optional groups / sections rendering field errors when empty.

## [5.0.0] - 2018-11-07
### Added
- View strategy selector on examples website.

### Changed
- Render fields inside HTML `label` for accessibility in `Form.View.asHtml`.
  The previous `label` elements are now `div` elements with the `elm-form-label`
  class. To migrate, replace your old CSS rules `.elm-form label { ... }` with
  `.elm-form .elm-form-label { ... }`.

### Removed
- `Form.Value`. Elm 0.19 makes this module unnecessary! The API is simpler now,
  allowing you to work with your types directly. To migrate, replace `Value a`
  with `a` and initialize your form values explicitly.

## [4.0.1] - 2018-09-02
### Changed
- Replace mentions of old `(,)` operator in docs with the new `Tuple.pair`
  equivalent in Elm 0.19.
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
- Fix CHANGELOG release links.
- Fix `Value.map` documentation example.
- Fix `stylish-elephants` custom renderer to work with `3.0.0`.

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

[Unreleased]: https://github.com/hecrj/composable-form/compare/8.0.0...HEAD
[8.0.0]: https://github.com/hecrj/composable-form/compare/7.1.0...8.0.0
[7.1.0]: https://github.com/hecrj/composable-form/compare/7.0.2...7.1.0
[7.0.2]: https://github.com/hecrj/composable-form/compare/7.0.1...7.0.2
[7.0.1]: https://github.com/hecrj/composable-form/compare/7.0.0...7.0.1
[7.0.0]: https://github.com/hecrj/composable-form/compare/6.0.1...7.0.0
[6.0.1]: https://github.com/hecrj/composable-form/compare/6.0.0...6.0.1
[6.0.0]: https://github.com/hecrj/composable-form/compare/5.0.0...6.0.0
[5.0.0]: https://github.com/hecrj/composable-form/compare/4.0.1...5.0.0
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
[elephants-renderer-example]: https://github.com/hecrj/composable-form/blob/2.2.0/examples/src/Form/View/Elements.elm
