module Form.View
    exposing
        ( BasicConfig
        , Model
        , State(..)
        , basic
        , field
        , idle
        )

import Form exposing (Form)
import Form.Field as Field exposing (Field)
import Form.Value as Value
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events


type alias Model values =
    { values : values
    , state : State
    , showErrors : Bool
    }


type State
    = Idle
    | Loading
    | Error String


idle : values -> Model values
idle values =
    { values = values
    , state = Idle
    , showErrors = False
    }


type alias BasicConfig values msg =
    { onChange : Model values -> msg
    , action : String
    , loadingMessage : String
    }


basic : BasicConfig values msg -> Form values msg -> Model values -> Html msg
basic { onChange, action, loadingMessage } form model =
    let
        onSubmitMsg =
            case Form.result form model.values of
                Ok msg ->
                    if model.state == Loading then
                        Nothing
                    else
                        Just msg

                Err _ ->
                    if model.showErrors then
                        Nothing
                    else
                        Just (onChange { model | showErrors = True })

        onSubmit =
            onSubmitMsg
                |> Maybe.map (Events.onSubmit >> List.singleton)
                |> Maybe.withDefault []

        fieldToHtml =
            field
                { onChange = \values -> onChange { model | values = values }
                , disabled = model.state == Loading
                , showError = model.showErrors
                }
    in
    Html.form onSubmit
        (List.concat
            [ Form.fields form model.values
                |> List.map fieldToHtml
            , [ case model.state of
                    Error error ->
                        errorMessage (Just error)

                    _ ->
                        Html.text ""
              , Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (onSubmitMsg == Nothing)
                    ]
                    [ if model.state == Loading then
                        Html.text loadingMessage
                      else
                        Html.text action
                    ]
              ]
            ]
        )


type alias FieldConfig values msg =
    { onChange : values -> msg
    , disabled : Bool
    , showError : Bool
    }


field : FieldConfig values msg -> ( Field values, Maybe Field.Error ) -> Html msg
field { onChange, disabled, showError } ( field, maybeError ) =
    let
        error =
            if showError then
                Maybe.map errorToString maybeError
            else
                Nothing
    in
    case field of
        Field.Text { type_, attributes, state } ->
            let
                config =
                    { onInput = state.update >> onChange
                    , disabled = disabled
                    , label = attributes.label
                    , placeholder = attributes.placeholder
                    , value = Value.raw state.value |> Maybe.withDefault ""
                    , error = error
                    }
            in
            case type_ of
                Field.RawText ->
                    textField config

                Field.TextArea ->
                    textArea config

                Field.Password ->
                    passwordField config

                Field.Email ->
                    emailField config

        Field.Checkbox { attributes, state } ->
            checkboxField
                { checked = Value.raw state.value |> Maybe.withDefault False
                , disabled = disabled
                , onCheck = state.update >> onChange
                , label = attributes.label
                , error = error
                }

        Field.Select { options, attributes, state } ->
            selectField options
                { onInput = state.update >> onChange
                , disabled = disabled
                , label = attributes.label
                , placeholder = attributes.placeholder
                , value = Value.raw state.value |> Maybe.withDefault ""
                , error = error
                }


errorToString : Field.Error -> String
errorToString error =
    case error of
        Field.EmptyError ->
            "This field is required"

        Field.ParserError parserError ->
            parserError



-- TEXT FIELD


type alias TextFieldConfig msg =
    { onInput : String -> msg
    , disabled : Bool
    , value : String
    , error : Maybe String
    , label : String
    , placeholder : String
    }


textField : TextFieldConfig msg -> Html msg
textField =
    inputField "text"



-- PASSWORD FIELD


type alias PasswordFieldConfig msg =
    TextFieldConfig msg


passwordField : PasswordFieldConfig msg -> Html msg
passwordField =
    inputField "password"



-- EMAIL FIELD


type alias EmailFieldConfig msg =
    TextFieldConfig msg


emailField : EmailFieldConfig msg -> Html msg
emailField =
    inputField "email"



-- TEXT AREA


type alias TextAreaConfig msg =
    TextFieldConfig msg


textArea : TextAreaConfig msg -> Html msg
textArea { onInput, disabled, value, error, label, placeholder } =
    Html.div []
        [ fieldLabel label
        , Html.textarea
            [ Events.onInput onInput
            , Attributes.disabled disabled
            , Attributes.placeholder placeholder
            ]
            []
        , errorMessage error
        ]



-- CHECKBOX FIELD


type alias CheckboxFieldConfig msg =
    { checked : Bool
    , disabled : Bool
    , onCheck : Bool -> msg
    , label : String
    , error : Maybe String
    }


checkboxField : CheckboxFieldConfig msg -> Html msg
checkboxField { checked, disabled, onCheck, label, error } =
    Html.div []
        [ Html.label []
            [ Html.input
                [ Events.onCheck onCheck
                , Attributes.checked checked
                , Attributes.disabled disabled
                , Attributes.type_ "checkbox"
                ]
                []
            , Html.text label
            ]
        , errorMessage error
        ]



-- SELECT FIELD


type alias SelectFieldConfig msg =
    TextFieldConfig msg


selectField : List ( String, String ) -> TextFieldConfig msg -> Html msg
selectField options { onInput, disabled, value, error, label, placeholder } =
    let
        toOption ( key, label ) =
            Html.option
                [ Attributes.value key
                , Attributes.selected (value == key)
                ]
                [ Html.text label ]

        placeholderOption =
            Html.option
                [ Attributes.disabled True
                , Attributes.selected (value == "")
                ]
                [ Html.text ("-- " ++ placeholder ++ " --") ]
    in
    Html.div []
        [ fieldLabel label
        , Html.select
            [ Events.onInput onInput
            , Attributes.disabled disabled
            ]
            (placeholderOption :: List.map toOption options)
        , errorMessage error
        ]



-- PRIVATE HELPERS


fieldLabel : String -> Html msg
fieldLabel label =
    Html.label [] [ Html.text label ]


errorMessage : Maybe String -> Html msg
errorMessage =
    Maybe.map (Html.text >> List.singleton >> Html.div [ Attributes.class "error" ])
        >> Maybe.withDefault (Html.text "")


inputField : String -> TextFieldConfig msg -> Html msg
inputField type_ { onInput, disabled, value, error, label, placeholder } =
    Html.div []
        [ fieldLabel label
        , Html.input
            [ Events.onInput onInput
            , Attributes.disabled disabled
            , Attributes.value value
            , Attributes.placeholder placeholder
            , Attributes.type_ type_
            ]
            []
        , errorMessage error
        ]
