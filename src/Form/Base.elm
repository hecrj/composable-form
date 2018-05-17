module Form.Base
    exposing
        ( FieldConfig
        , Form
        , append
        , custom
        , field
        , fields
        , optional
        , result
        , succeed
        )

import Form.Error as Error exposing (Error)
import Form.Field.State exposing (State)
import Form.Value as Value exposing (Value)


type
    Form values output field
    -- TODO: Merge into a single (values -> Internal field output) function
    = Form (List (FieldBuilder values field)) (values -> Result ( Error, List Error ) output)


type alias FieldBuilder values field =
    values -> ( field, Maybe Error )


fields : Form values output field -> values -> List ( field, Maybe Error )
fields (Form fields _) values =
    List.map (\builder -> builder values) fields


result : Form values output field -> values -> Result ( Error, List Error ) output
result (Form _ parser) =
    parser



-- CONSTRUCTORS


succeed : output -> Form values output custom
succeed output =
    Form [] (always (Ok output))



-- Custom fields


type alias BuildConfig attrs values input field =
    { builder : attrs -> State input values -> field
    , isEmpty : input -> Bool
    }


{-| Most form fields require configuration! `FieldConfig` allows you to specify how a field is
validated and updated, alongside its attributes:

  - `parser` must be a function that validates the `input` of the field and produces a correct
    `output` or a `String` describing a problem
  - `value` defines how the [`Value`](Form.Value) of the field is obtained from the form `values`
  - `update` defines how the current form `values` should be updated with a new field
    [`Value`](Form.Value)
  - `attributes` represent the attributes of the field

-}
type alias FieldConfig attrs input values output =
    { parser : input -> Result String output
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
                    Err ( Error.EmptyField, [] )

                Just value ->
                    if isEmpty value then
                        Err ( Error.EmptyField, [] )
                    else
                        config.parser value
                            |> Result.mapError (\error -> ( Error.ParserError error, [] ))

        parse =
            config.value >> Value.raw >> requiredParser

        update values newValue =
            let
                value =
                    config.value values

                result =
                    config.parser newValue
            in
            value
                |> Value.change newValue
                |> flip config.update values

        error values =
            case parse values of
                Ok _ ->
                    Nothing

                Err ( firstError, otherErrors ) ->
                    Just firstError

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
    , result : values -> Result ( Error, List Error ) output
    }


custom : CustomFieldConfig values output custom -> Form values output custom
custom { builder, result } =
    Form [ builder ] result



-- OPERATIONS


optional : Form values output custom -> Form values (Maybe output) custom
optional (Form builders output) =
    let
        optionalBuilder builder values =
            case builder values of
                ( field, Just Error.EmptyField ) ->
                    ( field, Nothing )

                result ->
                    result

        optionalOutput values =
            case output values of
                Ok value ->
                    Ok (Just value)

                Err ( firstError, otherErrors ) ->
                    if List.all ((==) Error.EmptyField) (firstError :: otherErrors) then
                        Ok Nothing
                    else
                        Err ( firstError, otherErrors )
    in
    Form (List.map optionalBuilder builders) optionalOutput


append : Form values a custom -> Form values (a -> b) custom -> Form values b custom
append (Form newFields newOutput) (Form fields output) =
    Form (fields ++ newFields)
        (\values ->
            case output values of
                Ok f ->
                    newOutput values
                        |> Result.map f

                Err (( firstError, otherErrors ) as errors) ->
                    case newOutput values of
                        Ok _ ->
                            Err errors

                        Err ( newFirstError, newOtherErrors ) ->
                            Err ( firstError, otherErrors ++ (newFirstError :: newOtherErrors) )
        )
