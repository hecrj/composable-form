module Form.Base.RadioField exposing
    ( RadioField, Attributes
    , form
    )

{-| This module contains a reusable `RadioField` type.


# Definition

@docs RadioField, Attributes


# Helpers

@docs form

-}

import Form.Base as Form exposing (Form)
import Form.Field exposing (Field)


{-| Represents a radio field.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

-}
type alias RadioField values =
    Field Attributes String values


{-| The attributes of a RadioField.

You need to provide these to:

  - [`Form.radioField`][radioField]

[radioField]: Form#radioField

-}
type alias Attributes =
    { label : String
    , options : List ( String, String )
    }


{-| Builds a [`Form`](Form-Base#Form) with a single `RadioField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (RadioField values -> field)
    -> Form.FieldConfig Attributes String values output
    -> Form values output field
form =
    Form.field { isEmpty = String.isEmpty }
