module Form.Error exposing (Error(..))

{-| This module contains a form [`Error`](#Error) type.

**Note:** You should not need to care about this unless you are writing
custom view code.

@docs Error

-}


{-| Represents a form error.

It can either be:

  - `RequiredFieldIsEmpty`, meaning that a required field is empty.
  - `ValidationFailed`, meaning the field validation has failed. This type of
    error contains a `String` describing the validation error.
  - `External`, meaning the field has an external error that cannot be validated
    on the client. This mostly contains errors directly assigned to the field
    on form construction using the `error` attribute.

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
    | External String
