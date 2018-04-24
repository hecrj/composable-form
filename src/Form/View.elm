module Form.View
    exposing
        ( BasicConfig
        , Model
        , State(..)
        , Validation(..)
        , basic
        , errorMessage
        , field
        , idle
        )

import Form exposing (Form)
import Form.Field as Field exposing (Field)
import Form.Value as Value
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Set exposing (Set)


type alias Model values =
    { values : values
    , state : State
    , showAllErrors : Bool
    , showFieldError : Set String
    }


type State
    = Idle
    | Loading
    | Error String


idle : values -> Model values
idle values =
    { values = values
    , state = Idle
    , showAllErrors = False
    , showFieldError = Set.empty
    }


type alias BasicConfig values msg =
    { onChange : Model values -> msg
    , action : String
    , loadingMessage : String
    , validation : Validation
    }


type Validation
    = ValidateOnSubmit
    | ValidateOnBlur


basic : BasicConfig values msg -> Form values msg -> Model values -> Html msg
basic { onChange, action, loadingMessage, validation } form model =
    let
        onSubmitMsg =
            case Form.result form model.values of
                Ok msg ->
                    if model.state == Loading then
                        Nothing
                    else
                        Just msg

                Err _ ->
                    if model.showAllErrors then
                        Nothing
                    else
                        Just (onChange { model | showAllErrors = True })

        onSubmit =
            onSubmitMsg
                |> Maybe.map (Events.onSubmit >> List.singleton)
                |> Maybe.withDefault []

        fieldToHtml =
            field
                { onChange = \values -> onChange { model | values = values }
                , onBlur = onBlur
                , disabled = model.state == Loading
                , showError = showError
                }

        onBlur =
            case validation of
                ValidateOnSubmit ->
                    Nothing

                ValidateOnBlur ->
                    Just (\label -> onChange { model | showFieldError = Set.insert label model.showFieldError })

        showError label =
            model.showAllErrors || Set.member label model.showFieldError
    in
    Html.form (Attributes.class "elm-form" :: onSubmit)
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



-- FIELD


type alias FieldConfig values msg =
    { onChange : values -> msg
    , onBlur : Maybe (String -> msg)
    , disabled : Bool
    , showError : String -> Bool
    }


field : FieldConfig values msg -> ( Field values, Maybe Field.Error ) -> Html msg
field { onChange, onBlur, disabled, showError } ( field, maybeError ) =
    let
        error label value =
            if showError label then
                Maybe.map errorToString maybeError
            else
                Nothing

        whenDirty value x =
            if Value.isDirty value then
                x
            else
                Nothing
    in
    case field of
        Field.Text { type_, attributes, state } ->
            let
                config =
                    { onInput = state.update >> onChange
                    , onBlur = whenDirty state.value (Maybe.map (\onBlur -> onBlur attributes.label) onBlur)
                    , disabled = disabled
                    , label = attributes.label
                    , placeholder = attributes.placeholder
                    , value = Value.raw state.value |> Maybe.withDefault ""
                    , error = error attributes.label state.value
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
                , error = error attributes.label state.value
                }

        Field.Select { options, attributes, state } ->
            selectField options
                { onInput = state.update >> onChange
                , onBlur = whenDirty state.value (Maybe.map (\onBlur -> onBlur attributes.label) onBlur)
                , disabled = disabled
                , label = attributes.label
                , placeholder = attributes.placeholder
                , value = Value.raw state.value |> Maybe.withDefault ""
                , error = error attributes.label state.value
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
    , onBlur : Maybe msg
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
    Html.div [ Attributes.class "elm-form-field" ]
        [ fieldLabel label
        , Html.textarea
            [ Events.onInput onInput
            , Attributes.disabled disabled
            , Attributes.placeholder placeholder
            ]
            [ Html.text value ]
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
    Html.div
        [ Attributes.classList
            [ ( "elm-form-field", True )
            , ( "elm-form-field-error", error /= Nothing )
            ]
        ]
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
selectField options { onInput, onBlur, disabled, value, error, label, placeholder } =
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

        fixedAttributes =
            [ Events.onInput onInput
            , Attributes.disabled disabled
            ]

        attributes =
            Maybe.map (Events.onBlur >> flip (::) fixedAttributes) onBlur
                |> Maybe.withDefault fixedAttributes
    in
    Html.div
        [ Attributes.classList
            [ ( "elm-form-field", True )
            , ( "elm-form-field-error", error /= Nothing )
            ]
        ]
        [ fieldLabel label
        , Html.select attributes
            (placeholderOption :: List.map toOption options)
        , errorMessage error
        ]



-- PRIVATE HELPERS


fieldLabel : String -> Html msg
fieldLabel label =
    Html.label [] [ Html.text label ]


errorMessage : Maybe String -> Html msg
errorMessage =
    Maybe.map (Html.text >> List.singleton >> Html.div [ Attributes.class "elm-form-error" ])
        >> Maybe.withDefault (Html.text "")


inputField : String -> TextFieldConfig msg -> Html msg
inputField type_ { onInput, onBlur, disabled, value, error, label, placeholder } =
    let
        fixedAttributes =
            [ Events.onInput onInput
            , Attributes.disabled disabled
            , Attributes.value value
            , Attributes.placeholder placeholder
            , Attributes.type_ type_
            ]

        attributes =
            Maybe.map (Events.onBlur >> flip (::) fixedAttributes) onBlur
                |> Maybe.withDefault fixedAttributes
    in
    Html.div
        [ Attributes.classList
            [ ( "elm-form-field", True )
            , ( "elm-form-field-error", error /= Nothing )
            ]
        ]
        [ fieldLabel label
        , Html.input attributes
            []
        , errorMessage error
        ]
