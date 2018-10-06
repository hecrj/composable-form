module Form.Base.TextField exposing
    ( TextField, Attributes
    , form
    )

{-| This module contains a reusable `TextField` type.


# Definition

@docs TextField, Attributes


# Helpers

@docs form

-}

import Form.Base as Base
import Form.Field exposing (Field)


{-| Represents a text field.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

-}
type alias TextField values =
    Field Attributes String values


{-| The attributes of a TextField.

You need to provide these to:

  - [`Form.textField`][textField]
  - [`Form.emailField`][emailField]
  - [`Form.passwordField`][passwordField]
  - [`Form.textareaField`][textareaField]

[textField]: Form#textField
[emailField]: Form#emailField
[passwordField]: Form#passwordField
[textareaField]: Form#textareaField

-}
type alias Attributes =
    { label : String
    , placeholder : String
    }


{-| Builds a [`Form`](Form-Base#Form) with a single `TextField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (TextField values -> field)
    -> Base.FieldConfig Attributes String values output
    -> Base.Form values output field
form =
    Base.field { isEmpty = String.isEmpty }
