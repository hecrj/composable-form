module Form.Base
    exposing
        ( FieldConfig
        , Filled
        , Form
        , andThen
        , append
        , custom
        , field
        , fill
        , meta
        , optional
        , succeed
        )

import Form.Error as Error exposing (Error)
import Form.Field.State exposing (State)
import Form.Field.Value as Value exposing (Value)


type Form values output field
    = Form (values -> Filled field output)


type alias Filled field output =
    { fields : List ( field, Maybe Error )
    , result : Result ( Error, List Error ) output
    }


type alias FieldBuilder values field =
    values -> ( field, Maybe Error )


fill : Form values output field -> values -> Filled field output
fill (Form fill_) =
    fill_



-- CONSTRUCTORS


succeed : output -> Form values output custom
succeed output =
    Form (always { fields = [], result = Ok output })



-- Custom fields


type alias GenericField attributes input values =
    { attributes : attributes
    , state : State input values
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


field :
    { isEmpty : input -> Bool }
    -> (GenericField attributes input values -> field)
    -> FieldConfig attributes input values output
    -> Form values output field
field { isEmpty } build config =
    let
        requiredParser maybeValue =
            case maybeValue of
                Nothing ->
                    Err ( Error.RequiredFieldIsEmpty, [] )

                Just value ->
                    if isEmpty value then
                        Err ( Error.RequiredFieldIsEmpty, [] )
                    else
                        config.parser value
                            |> Result.mapError (\error -> ( Error.ValidationFailed error, [] ))

        parse =
            config.value >> Value.raw >> requiredParser

        field values =
            let
                value =
                    config.value values

                update newValue =
                    value
                        |> Value.update newValue
                        |> flip config.update values
            in
            build
                { attributes = config.attributes
                , state = { value = value, update = update }
                }
    in
    Form
        (\values ->
            let
                result =
                    parse values
            in
            { fields =
                [ ( field values
                  , case result of
                        Ok _ ->
                            Nothing

                        Err ( firstError, _ ) ->
                            Just firstError
                  )
                ]
            , result = result
            }
        )


type alias FilledField output field =
    ( field, Result ( Error, List Error ) output )


custom : (values -> FilledField output custom) -> Form values output custom
custom fillField =
    Form
        (\values ->
            let
                ( field, result ) =
                    fillField values
            in
            { fields =
                [ ( field
                  , case result of
                        Ok _ ->
                            Nothing

                        Err ( firstError, _ ) ->
                            Just firstError
                  )
                ]
            , result = result
            }
        )



-- OPERATIONS


append : Form values a custom -> Form values (a -> b) custom -> Form values b custom
append new current =
    Form
        (\values ->
            let
                filledNew =
                    fill new values

                filledCurrent =
                    fill current values

                fields =
                    filledCurrent.fields ++ filledNew.fields
            in
            case filledCurrent.result of
                Ok f ->
                    { fields = fields
                    , result =
                        filledNew.result
                            |> Result.map f
                    }

                Err (( firstError, otherErrors ) as errors) ->
                    case filledCurrent.result of
                        Ok _ ->
                            { fields = fields
                            , result = Err errors
                            }

                        Err ( newFirstError, newOtherErrors ) ->
                            { fields = fields
                            , result =
                                Err
                                    ( firstError
                                    , otherErrors ++ (newFirstError :: newOtherErrors)
                                    )
                            }
        )


andThen : (a -> Form values b field) -> Form values a field -> Form values b field
andThen child parent =
    Form
        (\values ->
            let
                filled =
                    fill parent values
            in
            case filled.result of
                Ok output ->
                    let
                        childFilled =
                            fill (child output) values
                    in
                    { fields = filled.fields ++ childFilled.fields
                    , result = childFilled.result
                    }

                Err errors ->
                    { fields = filled.fields
                    , result = Err errors
                    }
        )


optional : Form values output custom -> Form values (Maybe output) custom
optional form =
    Form
        (\values ->
            let
                filled =
                    fill form values
            in
            case filled.result of
                Ok value ->
                    { fields = filled.fields
                    , result = Ok (Just value)
                    }

                Err ( firstError, otherErrors ) ->
                    let
                        allErrors =
                            firstError :: otherErrors
                    in
                    if
                        List.length allErrors
                            == List.length filled.fields
                            && List.all ((==) Error.RequiredFieldIsEmpty) allErrors
                    then
                        { fields = filled.fields
                        , result = Ok Nothing
                        }
                    else
                        { fields = filled.fields
                        , result = Err ( firstError, otherErrors )
                        }
        )


meta : (values -> Form values output field) -> Form values output field
meta fn =
    Form (\values -> fill (fn values) values)
