module Form.Base
    exposing
        ( FieldConfig
        , Form
        , Parser
        , append
        , appendMeta
        , custom
        , empty
        , field
        , fields
        , optional
        , result
        )

import Form.Error as Error exposing (Error)
import Form.Field.State exposing (State)
import Form.Value as Value exposing (Value)
import List.Nonempty exposing (Nonempty)


-- FORM


type Form values output field
    = Form (List (FieldBuilder values field)) (values -> Result (Nonempty Error) output)


type alias FieldBuilder values field =
    values -> ( field, Maybe Error )


type alias Parser a b =
    a -> Result String b


fields : Form values output field -> values -> List ( field, Maybe Error )
fields (Form fields_ _) values =
    List.map (\builder -> builder values) fields_


result : Form values output field -> values -> Result (Nonempty Error) output
result (Form _ parser) =
    parser



-- CONSTRUCTORS


empty : output -> Form values output custom
empty output =
    Form [] (always (Ok output))



-- CHECKBOX FIELD
-- Custom fields


type alias BuildConfig attrs values input field =
    { builder : attrs -> State input values -> field
    , isEmpty : input -> Bool
    }


type alias FieldConfig attrs input values output =
    { parser : Parser input output
    , value : values -> Value input
    , update : Value input -> values -> values
    , attributes : attrs
    }


field : BuildConfig attrs values input field -> (field -> custom) -> FieldConfig attrs input values output -> Form values output custom
field { builder, isEmpty } map config =
    let
        requiredParser maybeValue =
            case maybeValue of
                Nothing ->
                    Err (List.Nonempty.fromElement Error.EmptyField)

                Just value ->
                    if isEmpty value then
                        Err (List.Nonempty.fromElement Error.EmptyField)
                    else
                        config.parser value
                            |> Result.mapError (Error.ParserError >> List.Nonempty.fromElement)

        parse =
            config.value >> Value.raw >> requiredParser

        update values newValue =
            let
                value =
                    config.value values
            in
            value
                |> Value.change newValue
                |> (\v -> config.update v values)

        error values =
            case parse values of
                Ok _ ->
                    Nothing

                Err errors ->
                    Just (List.Nonempty.head errors)

        attributes values =
            { value = config.value values
            , update = update values
            }

        fieldBuilder values =
            ( builder config.attributes (attributes values) |> map, error values )
    in
    Form [ fieldBuilder ] parse


type alias CustomFieldConfig values output field =
    { builder : FieldBuilder values field
    , result : values -> Result (Nonempty Error) output
    }


custom : CustomFieldConfig values output custom -> Form values output custom
custom config =
    Form [ config.builder ] config.result



-- OPERATIONS


optional : Form values output custom -> Form values (Maybe output) custom
optional (Form builders output) =
    let
        optionalBuilder builder values =
            case builder values of
                ( field_, Just Error.EmptyField ) ->
                    ( field_, Nothing )

                result_ ->
                    result_

        optionalOutput values =
            case output values of
                Ok value ->
                    Ok (Just value)

                Err errors ->
                    if List.Nonempty.all ((==) Error.EmptyField) errors then
                        Ok Nothing
                    else
                        Err errors
    in
    Form (List.map optionalBuilder builders) optionalOutput


append : Form values a custom -> Form values (a -> b) custom -> Form values b custom
append (Form newFields newOutput) (Form fields_ output) =
    Form (fields_ ++ newFields)
        (\values ->
            case output values of
                Ok f ->
                    newOutput values
                        |> Result.map f

                Err errors ->
                    case newOutput values of
                        Ok _ ->
                            Err errors

                        Err newErrors ->
                            Err (List.Nonempty.append errors newErrors)
        )


appendMeta : Form values a custom -> Form values b custom -> Form values b custom
appendMeta (Form newFields newOutput) (Form fields_ output) =
    Form (fields_ ++ newFields)
        (\values ->
            newOutput values
                |> Result.andThen (always (output values))
        )
