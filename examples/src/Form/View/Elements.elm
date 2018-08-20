module Form.View.Elements exposing (asElement)

import Color
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Form exposing (Form)
import Form.Error as Error exposing (Error)
import Form.View
    exposing
        ( CheckboxFieldConfig
        , CustomConfig
        , FormConfig
        , Model
        , NumberFieldConfig
        , RadioFieldConfig
        , RangeFieldConfig
        , SelectFieldConfig
        , State(..)
        , TextFieldConfig
        , ViewConfig
        )
import Html
import Html.Attributes


{-| To use this in the example pages, in each of the `view` functions, replace:

    ...
    , Form.View.asHtml
    ...

with

    ...
    import Form.View.Elements
    import Element
    import Element.Font as Font
    ...
    , Element.layout
        [ Font.size 16
        , Font.family
            [ Font.external
                { url = "https://fonts.googleapis.com/css?family=Source+Sans+Pro"
                , name = "Source Sans Pro"
                }
            , Font.sansSerif
            ]
        ]
      <|
        Form.View.Elements.asElement
      ...

-}
asElement : ViewConfig values msg -> Form values msg -> Model values -> Element msg
asElement =
    Form.View.custom
        { form = form
        , textField = inputField Input.text
        , emailField = inputField Input.email
        , passwordField = passwordField
        , searchField = inputField Input.search
        , textareaField = textareaField
        , numberField = numberField
        , rangeField = rangeField
        , checkboxField = checkboxField
        , radioField = radioField
        , selectField = selectField
        , group = group
        }


form : FormConfig msg (Element msg) -> Element msg
form { onSubmit, action, loading, state, fields } =
    let
        submitButton =
            Input.button
                (button.shape
                    ++ (if onSubmit == Nothing then
                            button.disabledColors
                        else
                            button.enabledColors
                       )
                )
                { onPress = onSubmit
                , label =
                    if state == Loading then
                        text loading
                    else
                        text action
                }

        formError =
            case state of
                Error error ->
                    el [ Font.color errorColor ] (text error)

                _ ->
                    none
    in
    column [ spacing 16 ] (fields ++ [ formError, submitButton ])


inputField :
    (List (Attribute msg)
     ->
        { onChange : Maybe (String -> msg)
        , text : String
        , placeholder : Maybe (Input.Placeholder msg)
        , label : Input.Label msg
        }
     -> Element msg
    )
    -> TextFieldConfig msg
    -> Element msg
inputField input { onChange, onBlur, disabled, value, error, showError, attributes } =
    input
        ([]
            |> withCommonAttrs showError error disabled onBlur
        )
        { onChange = maybeOnChange disabled onChange
        , text = value
        , placeholder = placeholder attributes
        , label = labelAbove (showError && error /= Nothing) attributes
        }


passwordField : TextFieldConfig msg -> Element msg
passwordField { onChange, onBlur, disabled, value, error, showError, attributes } =
    Input.currentPassword
        ([]
            |> withCommonAttrs showError error disabled onBlur
        )
        { onChange = maybeOnChange disabled onChange
        , text = value
        , placeholder = placeholder attributes
        , label = labelAbove (showError && error /= Nothing) attributes
        , show = False
        }


textareaField : TextFieldConfig msg -> Element msg
textareaField { onChange, onBlur, disabled, value, error, showError, attributes } =
    Input.multiline
        ([ height shrink ]
            |> withCommonAttrs showError error disabled onBlur
        )
        { onChange = maybeOnChange disabled onChange
        , text = value
        , placeholder = placeholder attributes
        , label = labelAbove (showError && error /= Nothing) attributes
        , spellcheck = True
        }


numberField : NumberFieldConfig msg -> Element msg
numberField { onChange, onBlur, disabled, value, error, showError, attributes } =
    Input.text
        ([]
            |> withHtmlAttribute Html.Attributes.type_ (Just "number")
            |> withHtmlAttribute (toString >> Html.Attributes.step) (Just attributes.step)
            |> withHtmlAttribute (toString >> Html.Attributes.max) attributes.max
            |> withHtmlAttribute (toString >> Html.Attributes.min) attributes.min
            |> withCommonAttrs showError error disabled onBlur
        )
        { onChange = maybeOnChange disabled (fromString String.toFloat value >> onChange)
        , text = value |> Maybe.map toString |> Maybe.withDefault ""
        , placeholder = placeholder attributes
        , label = labelAbove (showError && error /= Nothing) attributes
        }


rangeField : RangeFieldConfig msg -> Element msg
rangeField { onChange, onBlur, disabled, value, error, showError, attributes } =
    Input.text
        ([]
            |> withHtmlAttribute Html.Attributes.type_ (Just "range")
            |> withHtmlAttribute (toString >> Html.Attributes.step) (Just attributes.step)
            |> withHtmlAttribute (toString >> Html.Attributes.max) attributes.max
            |> withHtmlAttribute (toString >> Html.Attributes.min) attributes.min
            |> withCommonAttrs showError error disabled onBlur
        )
        { onChange = maybeOnChange disabled (fromString String.toFloat value >> onChange)
        , text = value |> Maybe.map toString |> Maybe.withDefault ""
        , placeholder = Nothing
        , label = labelAbove (showError && error /= Nothing) attributes
        }


checkboxField : CheckboxFieldConfig msg -> Element msg
checkboxField { onChange, onBlur, value, disabled, error, showError, attributes } =
    Input.checkbox
        ([ paddingXY 0 8 ]
            |> withCommonAttrs showError error False onBlur
        )
        { onChange = maybeOnChange disabled onChange
        , icon = Nothing
        , checked = value
        , label =
            labelRight (showError && error /= Nothing)
                attributes
        }


radioField : RadioFieldConfig msg -> Element msg
radioField { onChange, onBlur, disabled, value, error, showError, attributes } =
    Input.radio
        ([ spacing 10, paddingXY 0 8 ]
            |> withCommonAttrs showError error False onBlur
        )
        { onChange = maybeOnChange disabled onChange
        , selected = Just value
        , label = labelAbove (showError && error /= Nothing) attributes
        , options =
            List.map
                (\( value, name ) ->
                    Input.option value (text name)
                )
                attributes.options
        }


{-| There is no select field so use a radio instead
-}
selectField : SelectFieldConfig msg -> Element msg
selectField { onChange, onBlur, disabled, value, error, showError, attributes } =
    -- There is no Elements select field so use a radio instead
    radioField
        { onChange = onChange
        , onBlur = onBlur
        , disabled = disabled
        , value = value
        , error = error
        , showError = showError
        , attributes =
            { label = attributes.label
            , options = attributes.options
            }
        }


group : List (Element msg) -> Element msg
group =
    row [ spacing 12 ]


errorToString : Error -> String
errorToString error =
    case error of
        Error.RequiredFieldIsEmpty ->
            "This field is required"

        Error.ValidationFailed validationError ->
            validationError



-- Common Elements


placeholder : { r | placeholder : String } -> Maybe (Input.Placeholder msg)
placeholder attributes =
    Just
        (Input.placeholder []
            (el
                [ Font.color Color.gray
                ]
                (text attributes.placeholder)
            )
        )


labelCenterY : (List (Attribute msg) -> Element msg -> Input.Label msg) -> Bool -> { r | label : String } -> Input.Label msg
labelCenterY label showError attributes =
    el [ centerY ] (text attributes.label)
        |> label
            ([]
                |> when showError (Font.color errorColor)
            )


labelLeft : Bool -> { r | label : String } -> Input.Label msg
labelLeft showError attributes =
    labelCenterY Input.labelLeft showError attributes


labelRight : Bool -> { r | label : String } -> Input.Label msg
labelRight showError attributes =
    labelCenterY Input.labelRight showError attributes


labelAbove : Bool -> { r | label : String } -> Input.Label msg
labelAbove showError attributes =
    text attributes.label
        |> Input.labelAbove
            ([ paddingXY 0 8 ]
                |> when showError (Font.color errorColor)
            )


fieldError : String -> Element msg
fieldError error =
    el [ Font.color errorColor ] (text error)



-- Helpers


maybeOnChange : Bool -> msg -> Maybe msg
maybeOnChange disabled onChange =
    if disabled then
        Nothing
    else
        Just onChange


fromString : (String -> Result err a) -> Maybe a -> String -> Maybe a
fromString parse currentValue input =
    if String.isEmpty input then
        Nothing
    else
        parse input
            |> Result.toMaybe
            |> Maybe.map Just
            |> Maybe.withDefault currentValue


withCommonAttrs :
    Bool
    -> Maybe Error
    -> Bool
    -> Maybe msg
    -> List (Attribute msg)
    -> List (Attribute msg)
withCommonAttrs showError error disabled onBlur attrs =
    attrs
        |> when showError
            (below
                (error
                    |> Maybe.map errorToString
                    |> Maybe.map fieldError
                    |> Maybe.withDefault none
                )
            )
        |> whenJust onBlur Events.onLoseFocus
        |> when disabled (Background.color grayColor)


when : Bool -> Attribute msg -> List (Attribute msg) -> List (Attribute msg)
when test attr attrs =
    if test then
        attr :: attrs
    else
        attrs


whenJust :
    Maybe a
    -> (a -> Attribute msg)
    -> List (Attribute msg)
    -> List (Attribute msg)
whenJust maybeValue toAttribute attrs =
    Maybe.map (toAttribute >> flip (::) attrs) maybeValue
        |> Maybe.withDefault attrs


withHtmlAttribute :
    (a -> Html.Attribute msg)
    -> Maybe a
    -> List (Attribute msg)
    -> List (Attribute msg)
withHtmlAttribute toAttribute maybeValue attrs =
    Maybe.map (toAttribute >> htmlAttribute >> flip (::) attrs) maybeValue
        |> Maybe.withDefault attrs



-- Style


errorColor : Color.Color
errorColor =
    Color.rgb 255 0 0


grayColor : Color.Color
grayColor =
    Color.rgb 204 204 204


button :
    { shape : List (Attribute msg)
    , enabledColors : List (Attribute msg)
    , disabledColors : List (Attribute msg)
    }
button =
    { shape =
        [ alignRight
        , paddingXY 16 10
        , scale 1.2
        , Border.rounded 3
        ]
    , enabledColors =
        [ Background.color (Color.rgb 52 73 94)
        , Font.color Color.white
        , mouseOver [ Background.color (Color.rgb 32 55 77) ]
        ]
    , disabledColors =
        [ Background.color grayColor
        , Font.color (Color.rgb 136 136 136)
        ]
    }
