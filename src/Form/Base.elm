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
import Form.Field exposing (Field)
import Form.Value as Value exposing (Value)


type Form values output field
    = Form (values -> Filled field output)


type alias Filled field output =
    { fields : List ( field, Maybe Error )
    , result : Result ( Error, List Error ) output
    , isEmpty : Bool
    }


type alias FieldBuilder values field =
    values -> ( field, Maybe Error )


fill : Form values output field -> values -> Filled field output
fill (Form fill_) =
    fill_



-- CONSTRUCTORS


succeed : output -> Form values output custom
succeed output =
    Form (always { fields = [], result = Ok output, isEmpty = True })



-- Custom fields


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
    -> (Field attributes input values -> field)
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
                { value = value
                , update = update
                , attributes = config.attributes
                }
    in
    Form
        (\values ->
            let
                result =
                    parse values

                ( error, isEmpty ) =
                    case result of
                        Ok _ ->
                            ( Nothing, False )

                        Err ( firstError, _ ) ->
                            ( Just firstError, firstError == Error.RequiredFieldIsEmpty )
            in
            { fields = [ ( field values, error ) ]
            , result = result
            , isEmpty = isEmpty
            }
        )


type alias FilledField output field =
    { field : field
    , result : Result ( Error, List Error ) output
    , isEmpty : Bool
    }


custom : (values -> FilledField output custom) -> Form values output custom
custom fillField =
    Form
        (\values ->
            let
                { field, result, isEmpty } =
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
            , isEmpty = isEmpty
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

                isEmpty =
                    filledCurrent.isEmpty && filledNew.isEmpty
            in
            case filledCurrent.result of
                Ok f ->
                    { fields = fields
                    , result =
                        filledNew.result
                            |> Result.map f
                    , isEmpty = isEmpty
                    }

                Err (( firstError, otherErrors ) as errors) ->
                    case filledCurrent.result of
                        Ok _ ->
                            { fields = fields
                            , result = Err errors
                            , isEmpty = isEmpty
                            }

                        Err ( newFirstError, newOtherErrors ) ->
                            { fields = fields
                            , result =
                                Err
                                    ( firstError
                                    , otherErrors ++ (newFirstError :: newOtherErrors)
                                    )
                            , isEmpty = isEmpty
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
                    , isEmpty = filled.isEmpty && childFilled.isEmpty
                    }

                Err errors ->
                    { fields = filled.fields
                    , result = Err errors
                    , isEmpty = filled.isEmpty
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
                    , isEmpty = filled.isEmpty
                    }

                Err ( firstError, otherErrors ) ->
                    if filled.isEmpty then
                        { fields = List.map (\( field, _ ) -> ( field, Nothing )) filled.fields
                        , result = Ok Nothing
                        , isEmpty = True
                        }
                    else
                        { fields = filled.fields
                        , result = Err ( firstError, otherErrors )
                        , isEmpty = False
                        }
        )


meta : (values -> Form values output field) -> Form values output field
meta fn =
    Form (\values -> fill (fn values) values)
