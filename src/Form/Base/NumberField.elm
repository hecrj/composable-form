module Form.Base.NumberField exposing
    ( NumberField, Attributes
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
custom fields or writing custom view code.

-}
type alias NumberField number values =
    Field (Attributes number) String values


{-| The attributes of a NumberField.

You need to provide these to:

  - [`Form.numberField`][numberField]

[numberField]: Form#numberField

  - Its `step` is a Maybe -- `Nothing` represents the HTML attribute value of "any". If you want only integers allowed, use `Just 1`.

-}
type alias Attributes number =
    { label : String
    , placeholder : String
    , step : Maybe number
    , min : Maybe number
    , max : Maybe number
    }


{-| Builds a [`Form`](Form-Base#Form) with a single `NumberField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (NumberField number values -> field)
    -> Base.FieldConfig (Attributes number) String values output
    -> Base.Form values output field
form =
    Base.field { isEmpty = String.isEmpty }
