module Form.Base.CheckboxField
    exposing
        ( Attributes
        , CheckboxField
        , form
        )

{-| This module contains a reusable `CheckboxField` type.


# Definition

@docs CheckboxField, Attributes


# Helpers

@docs form

-}

import Form.Base as Base
import Form.Field.State exposing (State)
import Form.Value as Value


{-| A CheckboxField has some [`Attributes`](#Attributes) and some [`State`](Form-Field-State#State).

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing your own form renderer.

-}
type alias CheckboxField values =
    { attributes : Attributes
    , state : State Bool values
    }


{-| The attributes of a CheckboxField.

You need to provide these to:

  - [`Form.checkboxField`][checkboxField]

[checkboxField]: Form#checkboxField

-}
type alias Attributes =
    { label : String }


{-| Builds a [`Base.Form`](Form-Base#Form) with a single `CheckboxField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (CheckboxField values -> field)
    -> Base.FieldConfig Attributes Bool values output
    -> Base.Form values output field
form build { parser, value, update, attributes } =
    Base.field { isEmpty = always False }
        build
        { parser = parser
        , value = value >> Value.withDefault False
        , update = update
        , attributes = attributes
        }
