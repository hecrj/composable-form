module Form.Value exposing
    ( Value
    , blank, filled
    , raw
    , map
    )

{-| This module contains a value type for your form fields.


# Definition

@docs Value


# Constructors

@docs blank, filled


# Queries

@docs raw


# Mappings

@docs map

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



-- Mapping


{-| Transform a value.

For instance, this can be useful if you want to use a
[`Form.numberField`](Form#numberField) with a `Value Int` instead
of `Value Float`:

    numberOfApples : Form { r | number : Value Int } Int
    numberOfApples =
        Form.numberField
            { parser = round >> Ok
            , value = .number >> Value.map toFloat
            , update =
                \value values ->
                    { values | number = Value.map round value }
            , attributes =
                { label = "How many apples do you have?"
                , placeholder = "Type a number"
                , step = 1
                , min = Just 0
                , max = Nothing
                }
            }

-}
map : (a -> b) -> Value a -> Value b
map fn value =
    raw value
        |> Maybe.map (fn >> Filled)
        |> Maybe.withDefault Blank
