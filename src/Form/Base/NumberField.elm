module Form.Base.NumberField
    exposing
        ( Attributes
        , NumberField
        , form
        )

{-| This module contains a reusable `NumberField` type.


# Definition

@docs NumberField, Attributes


# Helpers

@docs form

-}

import Form.Base as Base
import Form.Field exposing (Field)


{-| Represents a number field.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing your own form renderer.

-}
type alias NumberField values =
    Field Attributes Float values


{-| The attributes of a NumberField.

You need to provide these to:

  - [`Form.numberField`][numberField]

[numberField]: Form#numberField

-}
type alias Attributes =
    { label : String
    , placeholder : String
    , step : Float
    , min : Maybe Float
    , max : Maybe Float
    }


{-| Builds a [`Form`](Form-Base#Form) with a single `NumberField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (NumberField values -> field)
    -> Base.FieldConfig Attributes Float values output
    -> Base.Form values output field
form =
    Base.field { isEmpty = always False }
