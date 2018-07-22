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
type alias RangeField values =
    Field Attributes Float values


{-| The attributes of a RangeField.

You need to provide these to:

  - [`Form.rangeField`][rangeField]

[rangeField]: Form#rangeField

-}
type alias Attributes =
    { label : String
    , step : Float
    , min : Maybe Float
    , max : Maybe Float
    }


{-| Builds a [`Form`](Form-Base#Form) with a single `RangeField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (RangeField values -> field)
    -> Base.FieldConfig Attributes Float values output
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
