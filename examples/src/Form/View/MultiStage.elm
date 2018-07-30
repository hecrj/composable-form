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
import Form.View as View
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
add form view_ (Build (Form stages currentForm)) =
    let
        viewStage =
            Form.fill form >> .result >> Result.map view_ >> Result.toMaybe

        newStage =
            Stage (Form.fill form >> .fields) viewStage
    in
    Form (stages ++ [ newStage ]) (currentForm |> Form.append form)
        |> Build


end : Form.Form values a -> Build values (a -> b) -> Form values b
end form build_ =
    case add form (always (Html.text "")) build_ of
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
                    Just (Stage _ view_) ->
                        case view_ model.values of
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
                    (\(Stage _ view_) ->
                        view_ model.values
                            |> Maybe.map (Html.map (always (onChange model)))
                            |> Maybe.withDefault (Html.text "error")
                    )

        currentStageFields =
            case stages |> List.drop model.stage |> List.head of
                Just (Stage builder _) ->
                    builder model.values
                        |> List.map
                            (renderField
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
                    errorMessage error

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


renderField : FieldConfig values msg -> ( Form.Field values, Maybe Error ) -> Html msg
renderField ({ onChange, onBlur, disabled, showError } as fieldConfig) ( field, maybeError ) =
    let
        blurWhenNotBlank value label =
            if Value.raw value == Nothing then
                Nothing
            else
                Maybe.map (\onBlur_ -> onBlur_ label) onBlur
    in
    case field of
        Form.Text type_ { attributes, value, update } ->
            let
                config =
                    { onChange = update >> onChange
                    , onBlur = blurWhenNotBlank value attributes.label
                    , disabled = disabled
                    , value = Value.raw value |> Maybe.withDefault ""
                    , error = maybeError
                    , showError = showError attributes.label
                    , attributes = attributes
                    }
            in
            case type_ of
                Form.TextRaw ->
                    inputField "text" config

                Form.TextArea ->
                    textareaField config

                Form.TextPassword ->
                    inputField "password" config

                Form.TextEmail ->
                    inputField "email" config

                Form.TextSearch ->
                    inputField "search" config

        Form.Number { attributes, value, update } ->
            numberField
                { onChange = update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Range { attributes, value, update } ->
            rangeField
                { onChange = update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Checkbox { attributes, value, update } ->
            checkboxField
                { onChange = update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value |> Maybe.withDefault False
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Radio { attributes, value, update } ->
            radioField
                { onChange = update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value |> Maybe.withDefault ""
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Select { attributes, value, update } ->
            selectField
                { onChange = update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value |> Maybe.withDefault ""
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Group fields ->
            group (List.map (renderField fieldConfig) fields)


inputField : String -> View.TextFieldConfig msg -> Html msg
inputField type_ { onChange, onBlur, disabled, value, error, showError, attributes } =
    Html.input
        ([ Events.onInput onChange
         , Attributes.disabled disabled
         , Attributes.value value
         , Attributes.placeholder attributes.placeholder
         , Attributes.type_ type_
         ]
            |> withMaybeAttribute Events.onBlur onBlur
        )
        []
        |> withLabelAndError attributes.label showError error


textareaField : View.TextFieldConfig msg -> Html msg
textareaField { onChange, onBlur, disabled, value, error, showError, attributes } =
    Html.textarea
        ([ Events.onInput onChange
         , Attributes.disabled disabled
         , Attributes.placeholder attributes.placeholder
         ]
            |> withMaybeAttribute Events.onBlur onBlur
        )
        [ Html.text value ]
        |> withLabelAndError attributes.label showError error


numberField : View.NumberFieldConfig msg -> Html msg
numberField { onChange, onBlur, disabled, value, error, showError, attributes } =
    let
        safeOnChange =
            String.toFloat
                >> Maybe.map onChange
                >> Maybe.withDefault (onChange (Maybe.withDefault 0 value))
    in
    Html.input
        ([ Events.onInput safeOnChange
         , Attributes.disabled disabled
         , Attributes.value (value |> Maybe.map String.fromFloat |> Maybe.withDefault "")
         , Attributes.placeholder attributes.placeholder
         , Attributes.type_ "number"
         , Attributes.step (String.fromFloat attributes.step)
         ]
            |> withMaybeAttribute (String.fromFloat >> Attributes.max) attributes.max
            |> withMaybeAttribute (String.fromFloat >> Attributes.min) attributes.min
            |> withMaybeAttribute Events.onBlur onBlur
        )
        []
        |> withLabelAndError attributes.label showError error


rangeField : View.RangeFieldConfig msg -> Html msg
rangeField { onChange, onBlur, disabled, value, error, showError, attributes } =
    let
        safeOnChange =
            String.toFloat
                >> Maybe.map onChange
                >> Maybe.withDefault (onChange (Maybe.withDefault 0 value))
    in
    Html.input
        ([ Events.onInput safeOnChange
         , Attributes.disabled disabled
         , Attributes.value (value |> Maybe.map String.fromFloat |> Maybe.withDefault "")
         , Attributes.type_ "range"
         , Attributes.step (String.fromFloat attributes.step)
         ]
            |> withMaybeAttribute (String.fromFloat >> Attributes.max) attributes.max
            |> withMaybeAttribute (String.fromFloat >> Attributes.min) attributes.min
            |> withMaybeAttribute Events.onBlur onBlur
        )
        []
        |> withLabelAndError attributes.label showError error


checkboxField : View.CheckboxFieldConfig msg -> Html msg
checkboxField { onChange, onBlur, value, disabled, error, showError, attributes } =
    [ Html.label []
        [ Html.input
            ([ Events.onCheck onChange
             , Attributes.checked value
             , Attributes.disabled disabled
             , Attributes.type_ "checkbox"
             ]
                |> withMaybeAttribute Events.onBlur onBlur
            )
            []
        , Html.text attributes.label
        ]
    , maybeErrorMessage showError error
    ]
        |> wrapInFieldContainer showError error


radioField : View.RadioFieldConfig msg -> Html msg
radioField { onChange, onBlur, disabled, value, error, showError, attributes } =
    let
        radio ( key, label ) =
            Html.label []
                [ Html.input
                    ([ Attributes.name attributes.label
                     , Attributes.value key
                     , Attributes.checked (value == key)
                     , Attributes.disabled disabled
                     , Attributes.type_ "radio"
                     , Events.onClick (onChange key)
                     ]
                        |> withMaybeAttribute Events.onBlur onBlur
                    )
                    []
                , Html.text label
                ]
    in
    Html.fieldset [] (List.map radio attributes.options)
        |> withLabelAndError attributes.label showError error


selectField : View.SelectFieldConfig msg -> Html msg
selectField { onChange, onBlur, disabled, value, error, showError, attributes } =
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
                [ Html.text ("-- " ++ attributes.placeholder ++ " --") ]
    in
    Html.select
        ([ Events.onInput onChange
         , Attributes.disabled disabled
         ]
            |> withMaybeAttribute Events.onBlur onBlur
        )
        (placeholderOption :: List.map toOption attributes.options)
        |> withLabelAndError attributes.label showError error


group : List (Html msg) -> Html msg
group =
    Html.div [ Attributes.class "elm-form-group" ]


wrapInFieldContainer : Bool -> Maybe Error -> List (Html msg) -> Html msg
wrapInFieldContainer showError error =
    Html.div
        [ Attributes.classList
            [ ( "elm-form-field", True )
            , ( "elm-form-field-error", showError && error /= Nothing )
            ]
        ]


withLabelAndError : String -> Bool -> Maybe Error -> Html msg -> Html msg
withLabelAndError label showError error fieldAsHtml =
    [ fieldLabel label
    , fieldAsHtml
    , maybeErrorMessage showError error
    ]
        |> wrapInFieldContainer showError error


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


withMaybeAttribute : (a -> Html.Attribute msg) -> Maybe a -> List (Html.Attribute msg) -> List (Html.Attribute msg)
withMaybeAttribute toAttribute maybeValue attrs =
    Maybe.map (toAttribute >> (\attr -> attr :: attrs)) maybeValue
        |> Maybe.withDefault attrs
