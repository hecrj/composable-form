module Form.Error
    exposing
        ( Error(..)
        )

{-| This module contains a form [`Error`](#Error) type.

@docs Error

**Note:** You should not need to care about this unless you are writing your own form renderer.

-}


{-| Represents a form error.

It can either be:

  - a `RequiredFieldIsEmpty`, meaning that a required field is empty
  - a `ValidationFailed`, meaning the field validation has failed. This type of error contains a
    `String` describing the validation error.

These type of errors are returned alongside each field in the [`Form.fields`](Form#fields) and
[`Form.Base.fields`](#Form-Base#fields) functions.

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
