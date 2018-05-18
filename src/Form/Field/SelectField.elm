module Form.Field.SelectField
    exposing
        ( Attributes
        , SelectField
        , form
        )

{-| This module contains a reusable `SelectField` type.


# Definition

@docs SelectField, Attributes


# Helpers

@docs form

-}

import Form.Base as Form exposing (Form)
import Form.Field.State exposing (State)


{-| A SelectField has some [`Attributes`](#Attributes) and some [`State`](Form-Field-State#State).

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing your own form renderer.

-}
type alias SelectField values =
    { attributes : Attributes
    , state : State String values
    }


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


{-| Builds a [`Base.Form`](Form-Base#Form) with a single `SelectField`.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (SelectField values -> field)
    -> Form.FieldConfig Attributes String values output
    -> Form values output field
form =
    Form.field { builder = SelectField, isEmpty = String.isEmpty }
