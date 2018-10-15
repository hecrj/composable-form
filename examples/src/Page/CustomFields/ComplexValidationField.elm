module Page.CustomFields.ComplexValidationField exposing
    ( Msg(..)
    , State
    , ValidationState(..)
    , init
    , result
    , update
    , validationState
    , value
    )

import Form.Error as Error exposing (Error)
import Process
import Task exposing (Task)


type State value output
    = State value (ValidationState value output)


type ValidationState value output
    = Loading
    | NotValidated
    | Validated value (Result Error output)


init : value -> State value output
init value_ =
    State value_ NotValidated


validationState : State value output -> ValidationState value output
validationState (State _ validationState_) =
    validationState_


type Msg value output
    = ValueChanged value
    | ValidateAfterChange value
    | ValueValidated value (Result String output)


update :
    (value -> Task String output)
    -> Msg value output
    -> State value output
    -> ( State value output, Cmd (Msg value output) )
update validate msg ((State value_ validationState_) as state) =
    case msg of
        ValueChanged newValue ->
            ( State newValue NotValidated
            , Process.sleep 1000
                |> Task.perform (always (ValidateAfterChange newValue))
            )

        ValidateAfterChange old ->
            if value_ == old then
                performValidation validate state

            else
                ( state, Cmd.none )

        ValueValidated target result_ ->
            if value_ == target then
                ( State value_ (Validated value_ (Result.mapError Error.ValidationFailed result_))
                , Cmd.none
                )

            else
                ( state, Cmd.none )


performValidation :
    (value -> Task String output)
    -> State value output
    -> ( State value output, Cmd (Msg value output) )
performValidation validate (State value_ validationState_) =
    let
        isAlreadyValidated =
            case validationState_ of
                Validated validatedValue _ ->
                    validatedValue == value_

                _ ->
                    False
    in
    if isAlreadyValidated then
        ( State value_ validationState_
        , Cmd.none
        )

    else
        ( State value_ Loading
        , validate value_
            |> Task.attempt (ValueValidated value_)
        )


value : State value output -> value
value (State value_ _) =
    value_


result : State value output -> Result Error output
result (State _ validationState_) =
    case validationState_ of
        Loading ->
            Err (Error.ValidationFailed "Validating...")

        NotValidated ->
            Err (Error.ValidationFailed "Not validated yet...")

        Validated _ result_ ->
            result_
