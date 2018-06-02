module Page.CustomFields.Form.View
    exposing
        ( Model
        , State(..)
        , ViewConfig
        , asHtml
        , idle
        )

import Form.Error as Error exposing (Error)
import Form.Value as Value
import Form.View
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Page.CustomFields.Form as Form exposing (Form)


type alias Model values =
    { values : values
    , state : State
    , errorTracking : ErrorTracking
    }


type State
    = Idle
    | Loading
    | Error String


type ErrorTracking
    = ErrorTracking { showAllErrors : Bool }


idle : values -> Model values
idle values =
    { values = values
    , state = Idle
    , errorTracking =
        ErrorTracking
            { showAllErrors = False
            }
    }


type alias ViewConfig values msg =
    { onChange : Model values -> msg
    , action : String
    , loading : String
    }


asHtml : ViewConfig values msg -> Form values msg msg -> Model values -> Html msg
asHtml { onChange, action, loading } form model =
    let
        { fields, result } =
            Form.fill form model.values

        internal =
            case model.errorTracking of
                ErrorTracking internal ->
                    internal

        onSubmit =
            case result of
                Ok msg ->
                    if model.state == Loading then
                        Nothing
                    else
                        Just msg

                Err _ ->
                    if internal.showAllErrors then
                        Nothing
                    else
                        Just
                            (onChange
                                { model
                                    | errorTracking = ErrorTracking { internal | showAllErrors = True }
                                }
                            )

        fieldToElement =
            field
                { disabled = model.state == Loading
                , showError = internal.showAllErrors
                }

        onSubmitEvent =
            onSubmit
                |> Maybe.map (Events.onSubmit >> List.singleton)
                |> Maybe.withDefault []
    in
    Html.form (Attributes.class "elm-form" :: onSubmitEvent)
        (List.concat
            [ List.map fieldToElement fields
            , [ case model.state of
                    Error error ->
                        errorMessage error

                    _ ->
                        Html.text ""
              , Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (onSubmit == Nothing)
                    ]
                    [ if model.state == Loading then
                        Html.text loading
                      else
                        Html.text action
                    ]
              ]
            ]
        )


field : { disabled : Bool, showError : Bool } -> ( Form.Field values msg, Maybe Error ) -> Html msg
field { disabled, showError } ( field, maybeError ) =
    case field of
        Form.Email { onInput, value, attributes } ->
            inputField "email"
                { onInput = onInput
                , onBlur = Nothing
                , value = Value.raw value |> Maybe.withDefault ""
                , disabled = disabled
                , error = maybeError
                , showError = showError
                , attributes = attributes
                }


inputField : String -> Form.View.TextFieldConfig msg -> Html msg
inputField type_ { onInput, disabled, value, error, showError, attributes } =
    Html.div
        [ Attributes.classList
            [ ( "elm-form-field", True )
            , ( "elm-form-field-error", showError && error /= Nothing )
            ]
        ]
        [ fieldLabel attributes.label
        , Html.input
            [ Events.onInput onInput
            , Attributes.disabled disabled
            , Attributes.value value
            , Attributes.placeholder attributes.placeholder
            , Attributes.type_ type_
            ]
            []
        , maybeErrorMessage showError error
        ]


fieldLabel : String -> Html msg
fieldLabel label =
    Html.label [] [ Html.text label ]


maybeErrorMessage : Bool -> Maybe Error -> Html msg
maybeErrorMessage showError maybeError =
    if showError then
        maybeError
            |> Maybe.map errorToString
            |> Maybe.map errorMessage
            |> Maybe.withDefault (Html.text "")
    else
        Html.text ""


errorMessage : String -> Html msg
errorMessage =
    Html.text >> List.singleton >> Html.div [ Attributes.class "elm-form-error" ]


errorToString : Error -> String
errorToString error =
    case error of
        Error.RequiredFieldIsEmpty ->
            "This field is required"

        Error.ValidationFailed validationError ->
            validationError
