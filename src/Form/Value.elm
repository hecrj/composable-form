module Form.Value
    exposing
        ( Value
        , blank
        , filled
        , raw
        , update
        )

{-| This module contains a value type for your form fields.


# Definition

@docs Value


# Constructors

@docs blank, filled


# Queries

@docs raw


# Updates

@docs update


# Comparisons

@docs newest

-}


{-| Represents a form field value.
-}
type Value a
    = Blank
    | Filled a



-- Constructors


{-| A blank value.

Use this to initialize the values of your empty fields:

    values : SignupValues
    values =
        { email = Value.blank
        , password = Value.blank
        , rememberMe = Value.blank
        }

-}
blank : Value a
blank =
    Blank


{-| Build an already filled value.

Use this when you are using forms to edit existing values:

    values : Profile -> ProfileValues
    values profile =
        { firstName = Value.filled profile.firstName
        , lastName = Value.filled profile.lastName
        }

-}
filled : a -> Value a
filled =
    Filled



-- Queries


{-| Obtain the data inside a [`Value`](#Value).

If the value is blank, it returns `Nothing`, else it returns `Just` the value.

**Note:** You should only be using this in [`meta` forms](Form#meta) or
custom view code.

-}
raw : Value a -> Maybe a
raw value =
    case value of
        Blank ->
            Nothing

        Filled v ->
            Just v



-- Update


{-| Update a value with new data.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
update : a -> Value a -> Value a
update v value =
    Filled v
