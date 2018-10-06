module Form.Base.SelectField exposing
    ( SelectField, Attributes
    , form
    )

{-| This module contains a reusable `SelectField` type.


# Definition

@docs SelectField, Attributes


# Helpers

@docs form

-}

import Form.Base as Form exposing (Form)
import Form.Field exposing (Field)


{-| Represents a select field.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

-}
type alias SelectField values =
    Field Attributes String values


{-| The attributes of a SelectField.

You need to provide these to:

  - [`Form.selectField`][selectField]

[selectField]: Form#selectField

-}
type alias Attributes =
    { label : String
    , placeholder : String
    , options : List ( String, String )
    }


{-| Builds a [`Form`](Form-Base#Form) with a single `SelectField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (SelectField values -> field)
    -> Form.FieldConfig Attributes String values output
    -> Form values output field
form =
    Form.field { isEmpty = String.isEmpty }
