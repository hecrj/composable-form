module Form.View.MultiStage
    exposing
        ( Build
        , Form
        , Model
        , State(..)
        , add
        , build
        , end
        , idle
        , view
        )

import Form
import Form.Error as Error exposing (Error)
import Form.Value as Value
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events


type Form values output
    = Form (List (Stage values)) (Form.Form values output)


type Stage values
    = Stage (values -> List ( Form.Field values, Maybe Error )) (values -> Maybe (Html Never))



-- Build


type Build values output
    = Build (Form values output)


build : output -> Build values output
build output =
    Form [] (Form.succeed output)
        |> Build


add : Form.Form values a -> (a -> Html Never) -> Build values (a -> b) -> Build values b
add form view (Build (Form stages currentForm)) =
    let
        viewStage =
            Form.fill form >> .result >> Result.map view >> Result.toMaybe

        newStage =
            Stage (Form.fill form >> .fields) viewStage
    in
    Form (stages ++ [ newStage ]) (currentForm |> Form.append form)
        |> Build


end : Form.Form values a -> Build values (a -> b) -> Form values b
end form build =
    case add form (always (Html.text "")) build of
        Build multiStageForm ->
            multiStageForm



-- View


type alias Model values =
    { values : values
    , state : State
    , stage : Int
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
    , stage = 0
    , showErrors = False
    }


type alias ViewConfig values msg =
    { onChange : Model values -> msg
    , action : String
    , loading : String
    , next : String
    , back : String
    }


view : ViewConfig values output -> Form values output -> Model values -> Html output
view { onChange, action, loading, next, back } (Form stages form) model =
    let
        isLastStage =
            model.stage + 1 == List.length stages

        currentStage =
            stages |> List.drop model.stage |> List.head

        maybeShowErrors =
            if model.showErrors then
                Nothing
            else
                Just (onChange { model | showErrors = True })

        filled =
            Form.fill form model.values

        onSubmitMsg =
            if isLastStage then
                case filled.result of
                    Ok msg ->
                        if model.state == Loading then
                            Nothing
                        else
                            Just msg

                    Err _ ->
                        maybeShowErrors
            else
                case currentStage of
                    Just (Stage _ view) ->
                        case view model.values of
                            Just _ ->
                                Just (onChange { model | stage = model.stage + 1, showErrors = False })

                            Nothing ->
                                maybeShowErrors

                    Nothing ->
                        Nothing

        onSubmit =
            onSubmitMsg
                |> Maybe.map (Events.onSubmit >> List.singleton)
                |> Maybe.withDefault []

        filledStages =
            List.take model.stage stages
                |> List.map
                    (\(Stage _ view) ->
                        view model.values
                            |> Maybe.map (Html.map (always (onChange model)))
                            |> Maybe.withDefault (Html.text "error")
                    )

        currentStageFields =
            case stages |> List.drop model.stage |> List.head of
                Just (Stage builder _) ->
                    builder model.values
                        |> List.map
                            (field
                                { onChange = \values -> onChange { model | values = values }
                                , onBlur = Nothing
                                , disabled = model.state == Loading
                                , showError = always model.showErrors
                                }
                            )

                Nothing ->
                    [ Html.text "" ]

        controls =
            [ case model.state of
                Error error ->
                    errorMessage (Just error)

                _ ->
                    Html.text ""
            , Html.div [ Attributes.class "elm-form-multistage-controls" ]
                [ if model.stage == 0 || model.state == Loading then
                    Html.div [] []
                  else
                    Html.a
                        [ Attributes.class "elm-form-multistage-back"
                        , Events.onClick (onChange { model | stage = model.stage - 1 })
                        ]
                        [ Html.text back ]
                , Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (onSubmitMsg == Nothing)
                    ]
                    [ if model.state == Loading then
                        Html.text loading
                      else if isLastStage then
                        Html.text action
                      else
                        Html.text next
                    ]
                ]
            ]
    in
    Html.form (Attributes.class "elm-form-multistage" :: onSubmit)
        (List.concat
            [ filledStages
            , currentStageFields
            , controls
            ]
        )



-- Rendering helpers


type alias FieldConfig values msg =
    { onChange : values -> msg
    , onBlur : Maybe (String -> msg)
    , disabled : Bool
    , showError : String -> Bool
    }


field : FieldConfig values msg -> ( Form.Field values, Maybe Error ) -> Html msg
field { onChange, onBlur, disabled, showError } ( field, maybeError ) =
    let
        error label value =
            if showError label then
                Maybe.map errorToString maybeError
            else
                Nothing

        whenDirty value x =
            if Value.raw value == Nothing then
                Nothing
            else
                x
    in
    case field of
        Form.Text type_ { attributes, value, update } ->
            let
                config =
                    { onInput = update >> onChange
                    , onBlur = whenDirty value (Maybe.map (\onBlur -> onBlur attributes.label) onBlur)
                    , disabled = disabled
                    , label = attributes.label
                    , placeholder = attributes.placeholder
                    , value = Value.raw value |> Maybe.withDefault ""
                    , error = error attributes.label value
                    }
            in
            case type_ of
                Form.TextRaw ->
                    textField config

                Form.TextArea ->
                    textArea config

                Form.TextPassword ->
                    passwordField config

                Form.TextEmail ->
                    emailField config

        Form.Checkbox { attributes, value, update } ->
            checkboxField
                { checked = Value.raw value |> Maybe.withDefault False
                , disabled = disabled
                , onCheck = update >> onChange
                , label = attributes.label
                , error = error attributes.label value
                }

        Form.Select { attributes, value, update } ->
            selectField attributes.options
                { onInput = update >> onChange
                , onBlur = whenDirty value (Maybe.map (\onBlur -> onBlur attributes.label) onBlur)
                , disabled = disabled
                , label = attributes.label
                , placeholder = attributes.placeholder
                , value = Value.raw value |> Maybe.withDefault ""
                , error = error attributes.label value
                }


errorToString : Error -> String
errorToString error =
    case error of
        Error.RequiredFieldIsEmpty ->
            "This field is required"

        Error.ValidationFailed validationError ->
            validationError



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
