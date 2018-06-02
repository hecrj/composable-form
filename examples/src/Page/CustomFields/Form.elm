module Page.CustomFields.Form
    exposing
        ( Field(..)
        , Form
        , andThen
        , append
        , customEmailField
        , fill
        , meta
        , optional
        , succeed
        )

import Form.Base as Base
import Form.Base.TextField as TextField exposing (TextField)
import Form.Error exposing (Error)
import Form.Value as Value exposing (Value)
import Page.CustomFields.ComplexValidationField as ComplexValidationField


-- Definition


type alias Form values output msg =
    Base.Form values output (Field values msg)



-- Fields


customEmailField :
    { toMsg : ComplexValidationField.Msg String output -> msg
    , state : values -> ComplexValidationField.State String output
    , attributes : TextField.Attributes
    }
    -> Form values output msg
customEmailField { toMsg, state, attributes } =
    let
        filledField values =
            let
                value =
                    state values
                        |> ComplexValidationField.value
            in
            { field =
                Email
                    { onInput = ComplexValidationField.InputChanged >> toMsg
                    , value = value
                    , attributes = attributes
                    }
            , result =
                state values
                    |> ComplexValidationField.result
                    |> Result.mapError (\error -> ( error, [] ))
            , isEmpty =
                Value.raw value
                    |> Maybe.withDefault ""
                    |> (==) ""
            }
    in
    Base.custom filledField



-- Composition


succeed : output -> Form values output msg
succeed =
    Base.succeed


append : Form values a msg -> Form values (a -> b) msg -> Form values b msg
append =
    Base.append


andThen : (a -> Form values b msg) -> Form values a msg -> Form values b msg
andThen =
    Base.andThen


optional : Form values output msg -> Form values (Maybe output) msg
optional =
    Base.optional


meta : (values -> Form values output msg) -> Form values output msg
meta =
    Base.meta



-- Output


type Field values msg
    = Email
        { onInput : String -> msg
        , value : Value String
        , attributes : TextField.Attributes
        }


fill :
    Form values output msg
    -> values
    ->
        { fields : List ( Field values msg, Maybe Error )
        , result : Result ( Error, List Error ) output
        , isEmpty : Bool
        }
fill =
    Base.fill
