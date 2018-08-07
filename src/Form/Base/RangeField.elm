module Form.Base.RangeField
    exposing
        ( Attributes
        , RangeField
        , form
        )

{-| This module contains a reusable `RangeField` type.


# Definition

@docs RangeField, Attributes


# Helpers

@docs form

-}

import Form.Base as Base
import Form.Field exposing (Field)
import Form.Value as Value


{-| Represents a range field.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

-}
type alias RangeField number values =
    Field (Attributes number) number values


{-| The attributes of a RangeField.

You need to provide these to:

  - [`Form.rangeField`][rangeField]

[rangeField]: Form#rangeField

-}
type alias Attributes number =
    { label : String
    , step : number
    , min : Maybe number
    , max : Maybe number
    }


{-| Builds a [`Form`](Form-Base#Form) with a single `RangeField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (RangeField number values -> field)
    -> Base.FieldConfig (Attributes number) number values output
    -> Base.Form values output field
form build { parser, value, update, attributes } =
    let
        withDefault v =
            Value.raw v
                |> Maybe.map (always v)
                |> Maybe.withDefault
                    (attributes.min
                        |> Maybe.map Value.filled
                        |> Maybe.withDefault Value.blank
                    )
    in
    Base.field { isEmpty = always False }
        build
        { parser = parser
        , value = value >> withDefault
        , update = update
        , attributes = attributes
        }
