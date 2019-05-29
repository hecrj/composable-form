module Form.Base.RangeField exposing
    ( RangeField, Attributes
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


{-| Represents a range field.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

-}
type alias RangeField number values =
    Field (Attributes number) (Maybe number) values


type alias Config number values output =
    Base.FieldConfig (Attributes number) (Maybe number) values output


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
    -> Config number values output
    -> Base.Form values output field
form build { parser, value, update, error, attributes } =
    let
        withDefault maybeValue =
            case maybeValue of
                Just v ->
                    Just v

                Nothing ->
                    attributes.min
    in
    Base.field { isEmpty = (==) Nothing }
        build
        { parser = parser
        , value = value >> withDefault
        , update = update
        , error = error
        , attributes = attributes
        }
