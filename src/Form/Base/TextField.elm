module Form.Base.TextField
    exposing
        ( Attributes
        , TextField
        , Type(..)
        , form
        )

{-| This module contains a reusable `TextField` type.


# Definition

@docs TextField, Attributes, Type


# Helpers

@docs form

-}

import Form.Base as Base
import Form.Field.State exposing (State)


{-| A TextField has some [`Attributes`](#Attributes) and some [`State`](Form-Field-State#State).

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing your own form renderer.

-}
type alias TextField values =
    { attributes : Attributes
    , state : State String values
    }


{-| Represents a type of text field
-}
type Type
    = Raw
    | Email
    | Password
    | Textarea


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


{-| Builds a [`Base.Form`](Form-Base#Form) with a single `TextField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (TextField values -> field)
    -> Base.FieldConfig Attributes String values output
    -> Base.Form values output field
form =
    Base.field { isEmpty = String.isEmpty }
