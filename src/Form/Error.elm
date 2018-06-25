module Form.Error
    exposing
        ( Error(..)
        )

{-| This module contains a form [`Error`](#Error) type.

**Note:** You should not need to care about this unless you are writing your own form renderer.

@docs Error

-}


{-| Represents a form error.

It can either be:

  - `RequiredFieldIsEmpty`, meaning that a required field is empty.
  - `ValidationFailed`, meaning the field validation has failed. This type of error contains a
    `String` describing the validation error.

These type of errors are returned alongside each field in the [`Form.fill`](Form#fill) and
[`Form.Base.fill`](Form-Base#fill) functions.

You can easily write a simple function that turns this type into a `String`:

    errorToString : Error -> String
    errorToString error =
        case error of
            Error.RequiredFieldIsEmpty ->
                "this field is required"

            Error.ValidationFailed errorDescription ->
                errorDescription

-}
type Error
    = RequiredFieldIsEmpty
    | ValidationFailed String
