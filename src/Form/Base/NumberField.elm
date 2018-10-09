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
    Field (Attributes number) (Maybe number) values


{-| The attributes of a NumberField.

You need to provide these to:

  - [`Form.numberField`][numberField]

[numberField]: Form#numberField

-}
type alias Attributes number =
    { label : String
    , placeholder : String
    , step : number
    , min : Maybe number
    , max : Maybe number
    }


{-| Builds a [`Form`](Form-Base#Form) with a single `NumberField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (NumberField number values -> field)
    -> Base.FieldConfig (Attributes number) (Maybe number) values output
    -> Base.Form values output field
form =
    Base.field { isEmpty = (==) Nothing }
