module Page.CustomFields.ComplexValidationField exposing
    ( Msg(..)
    , State
    , ValidationState(..)
    , blank
    , result
    , update
    , validationState
    , value
    )

import Form.Error as Error exposing (Error)
import Form.Value as Value exposing (Value)
import Process
import Task exposing (Task)


type State input output
    = State (Value input) (ValidationState (Value input) output)


type ValidationState input output
    = Loading
    | NotValidated
    | Validated input (Result Error output)


blank : State input output
blank =
    State Value.blank NotValidated


validationState : State input output -> ValidationState (Value input) output
validationState (State _ validationState_) =
    validationState_


type Msg input output
    = InputChanged input
    | ValidateAfterChange input
    | InputValidated input (Result String output)


update :
    (input -> Task String output)
    -> Msg input output
    -> State input output
    -> ( State input output, Cmd (Msg input output) )
update validate msg ((State value_ validationState_) as state) =
    case msg of
        InputChanged input ->
            ( State (Value.filled input) NotValidated
            , Process.sleep 1000
                |> Task.perform (always (ValidateAfterChange input))
            )

        ValidateAfterChange old ->
            if Value.raw value_ == Just old then
                performValidation validate state

            else
                ( state, Cmd.none )

        InputValidated target result_ ->
            if Value.raw value_ == Just target then
                ( State value_ (Validated value_ (Result.mapError Error.ValidationFailed result_))
                , Cmd.none
                )

            else
                ( state, Cmd.none )


performValidation :
    (input -> Task String output)
    -> State input output
    -> ( State input output, Cmd (Msg input output) )
performValidation validate (State value_ validationState_) =
    let
        isAlreadyValidated =
            case validationState_ of
                Validated validatedValue _ ->
                    Value.raw validatedValue == Value.raw value_

                _ ->
                    False
    in
    if isAlreadyValidated then
        ( State value_ validationState_
        , Cmd.none
        )

    else
        case Value.raw value_ of
            Just input ->
                ( State value_ Loading
                , validate input
                    |> Task.attempt (InputValidated input)
                )

            Nothing ->
                ( State value_ (Validated value_ (Err Error.RequiredFieldIsEmpty))
                , Cmd.none
                )


value : State input output -> Value input
value (State value_ _) =
    value_


result : State input output -> Result Error output
result (State _ validationState_) =
    case validationState_ of
        Loading ->
            Err (Error.ValidationFailed "Validating...")

        NotValidated ->
            Err (Error.ValidationFailed "Not validated yet...")

        Validated _ result_ ->
            result_
