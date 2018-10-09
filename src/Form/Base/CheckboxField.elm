module Form.Base.CheckboxField exposing
    ( CheckboxField, Attributes
    , form
    )

{-| This module contains a reusable `CheckboxField` type.


# Definition

@docs CheckboxField, Attributes


# Helpers

@docs form

-}

import Form.Base as Base
import Form.Field exposing (Field)


{-| Represents a checkbox field.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

-}
type alias CheckboxField values =
    Field Attributes Bool values


{-| The attributes of a CheckboxField.

You need to provide these to:

  - [`Form.checkboxField`][checkboxField]

[checkboxField]: Form#checkboxField

-}
type alias Attributes =
    { label : String }


{-| Builds a [`Form`](Form-Base#Form) with a single `CheckboxField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (CheckboxField values -> field)
    -> Base.FieldConfig Attributes Bool values output
    -> Base.Form values output field
form =
    Base.field { isEmpty = always False }
