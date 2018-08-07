module Page.CustomFields.ComplexValidationField
    exposing
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
import Time


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
validationState (State _ validationState) =
    validationState


type Msg input output
    = InputChanged input
    | ValidateAfterChange input
    | InputValidated input (Result String output)


update :
    (input -> Task String output)
    -> Msg input output
    -> State input output
    -> ( State input output, Cmd (Msg input output) )
update validate msg ((State value validationState) as state) =
    case msg of
        InputChanged input ->
            ( State (Value.update (Just input) value) NotValidated
            , Process.sleep (1 * Time.second)
                |> Task.perform (always (ValidateAfterChange input))
            )

        ValidateAfterChange old ->
            if Value.raw value == Just old then
                performValidation validate state
            else
                ( state, Cmd.none )

        InputValidated target result ->
            if Value.raw value == Just target then
                ( State value (Validated value (Result.mapError Error.ValidationFailed result))
                , Cmd.none
                )
            else
                ( state, Cmd.none )


performValidation :
    (input -> Task String output)
    -> State input output
    -> ( State input output, Cmd (Msg input output) )
performValidation validate (State value validationState) =
    let
        isAlreadyValidated =
            case validationState of
                Validated validatedValue _ ->
                    Value.raw validatedValue == Value.raw value

                _ ->
                    False
    in
    if isAlreadyValidated then
        ( State value validationState
        , Cmd.none
        )
    else
        case Value.raw value of
            Just input ->
                ( State value Loading
                , validate input
                    |> Task.attempt (InputValidated input)
                )

            Nothing ->
                ( State value (Validated value (Err Error.RequiredFieldIsEmpty))
                , Cmd.none
                )


value : State input output -> Value input
value (State value_ _) =
    value_


result : State input output -> Result Error output
result (State _ validationState) =
    case validationState of
        Loading ->
            Err (Error.ValidationFailed "Validating...")

        NotValidated ->
            Err (Error.ValidationFailed "Not validated yet...")

        Validated _ result ->
            result
