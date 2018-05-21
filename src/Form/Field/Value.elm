module Form.Field.Value
    exposing
        ( Value
        , blank
        , filled
        , newest
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
    = Blank Int
    | Filled Int a



-- Constructors


{-| A blank value.

Use this to initialize the values of your empty fields:

    values : SignupValues
    values =
        { email = Value.blank
        , password = Value.blank
        }

-}
blank : Value a
blank =
    Blank 0


{-| Build a filled value.

Use this when you are using forms to edit existing values:

    values : Profile -> ProfileValues
    values profile =
        { firstName = Value.filled profile.firstName
        , lastName = Value.filled profile.lastName
        }

-}
filled : a -> Value a
filled =
    Filled 0



-- Queries


{-| Obtain the data inside a [`Value`](#Value).

If the value is blank, it returns `Nothing`, else it returns `Just` the value.

**Note:** You should only be using this in [`meta` forms](Form#meta) or your own custom renderer.

-}
raw : Value a -> Maybe a
raw value =
    case value of
        Blank _ ->
            Nothing

        Filled _ v ->
            Just v



-- Update


{-| Update a value with new data.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
update : a -> Value a -> Value a
update v value =
    Filled (version value + 1) v



-- Comparisons


{-| Select the newest value out of two sets of values.

This is necessary to fix an issue with autocompletion. When a form is autocompleted, many events
can get triggered before the view can be rerendered, causing the first autocompleted values to be
lost.

`newest` allows to fix this:

    update : Msg -> Model -> Model
    update msg values =
        FormChanged newForm ->
            { form |
                values =
                    { email = Value.newest .email form.values newForm.values
                    , password = Value.newest .password form.values newForm.values
                    }
            }

**Note:** This issue _seems_ fixed in Elm 0.19. This whole module might be unnecessary soon.

-}
newest : (values -> Value a) -> values -> values -> Value a
newest getter values1 values2 =
    let
        value1 =
            getter values1

        value2 =
            getter values2
    in
    if version value1 >= version value2 then
        value1
    else
        value2



-- PRIVATE HELPERS


version : Value a -> Int
version value =
    case value of
        Blank version ->
            version

        Filled version _ ->
            version
