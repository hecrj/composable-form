module Form.View.Ui exposing (layout)

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
        , FormListConfig
        , FormListItemConfig
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


layout : ViewConfig values msg -> Form values msg -> Model values -> Element msg
layout =
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
        , section = section
        , formList = formList
        , formListItem = formListItem
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

        formFeedback =
            case state of
                Error error ->
                    el [ Font.color red ] (text error)

                Success success ->
                    el [ Font.color black ] (text success)

                _ ->
                    none
    in
    column [ spacing 16, width fill ] (fields ++ [ formFeedback, submitButton ])


inputField :
    (List (Attribute msg)
     ->
        { onChange : String -> msg
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
        { onChange = onChange
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
        { onChange = onChange
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
        { onChange = onChange
        , text = value
        , placeholder = placeholder attributes
        , label = labelAbove (showError && error /= Nothing) attributes
        , spellcheck = True
        }


numberField : NumberFieldConfig msg -> Element msg
numberField { onChange, onBlur, disabled, value, error, showError, attributes } =
    let
        stepAttr =
            attributes.step
                |> Maybe.map String.fromFloat
                |> Maybe.withDefault "any"
    in
    Input.text
        ([]
            |> withHtmlAttribute Html.Attributes.type_ (Just "number")
            |> withHtmlAttribute Html.Attributes.step (Just stepAttr)
            |> withHtmlAttribute (String.fromFloat >> Html.Attributes.max) attributes.max
            |> withHtmlAttribute (String.fromFloat >> Html.Attributes.min) attributes.min
            |> withCommonAttrs showError error disabled onBlur
        )
        { onChange = onChange
        , text = value
        , placeholder = placeholder attributes
        , label = labelAbove (showError && error /= Nothing) attributes
        }


rangeField : RangeFieldConfig msg -> Element msg
rangeField { onChange, onBlur, disabled, value, error, showError, attributes } =
    Input.text
        ([]
            |> withHtmlAttribute Html.Attributes.type_ (Just "range")
            |> withHtmlAttribute (String.fromFloat >> Html.Attributes.step) (Just attributes.step)
            |> withHtmlAttribute (String.fromFloat >> Html.Attributes.max) attributes.max
            |> withHtmlAttribute (String.fromFloat >> Html.Attributes.min) attributes.min
            |> withCommonAttrs showError error disabled onBlur
        )
        { onChange = fromString String.toFloat value >> onChange
        , text = value |> Maybe.map String.fromFloat |> Maybe.withDefault ""
        , placeholder = Nothing
        , label = labelAbove (showError && error /= Nothing) attributes
        }


checkboxField : CheckboxFieldConfig msg -> Element msg
checkboxField { onChange, onBlur, value, disabled, error, showError, attributes } =
    Input.checkbox
        ([ paddingXY 0 8 ]
            |> withCommonAttrs showError error False onBlur
        )
        { onChange = onChange
        , icon = Input.defaultCheckbox
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
        { onChange = onChange
        , selected = Just value
        , label = labelAbove (showError && error /= Nothing) attributes
        , options =
            List.map
                (\( val, name ) ->
                    Input.option val (text name)
                )
                attributes.options
        }


selectField : SelectFieldConfig msg -> Element msg
selectField { onChange, onBlur, disabled, value, error, showError, attributes } =
    -- There is no select field so use a radio instead
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


section : String -> List (Element msg) -> Element msg
section title fields =
    column
        [ Border.solid
        , Border.width 1
        , padding 20
        , width fill
        , inFront
            (el
                [ moveUp 14
                , moveRight 10
                , Background.color black
                , Font.color white
                , padding 6
                , width shrink
                ]
                (text title)
            )
        ]
        fields


formList : FormListConfig msg (Element msg) -> Element msg
formList { forms, add } =
    Element.none


formListItem : FormListItemConfig msg (Element msg) -> Element msg
formListItem { fields, delete } =
    Element.none


errorToString : Error -> String
errorToString error =
    case error of
        Error.RequiredFieldIsEmpty ->
            "This field is required"

        Error.ValidationFailed validationError ->
            validationError

        Error.External externalError ->
            externalError



-- Common Elements


placeholder : { r | placeholder : String } -> Maybe (Input.Placeholder msg)
placeholder attributes =
    Just
        (Input.placeholder []
            (el
                [ Font.color gray
                ]
                (text attributes.placeholder)
            )
        )


labelCenterY : (List (Attribute msg) -> Element msg -> Input.Label msg) -> Bool -> { r | label : String } -> Input.Label msg
labelCenterY label showError attributes =
    el [ centerY ] (text attributes.label)
        |> label
            ([]
                |> when showError (Font.color red)
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
                |> when showError (Font.color red)
            )


fieldError : String -> Element msg
fieldError error =
    el [ Font.color red ] (text error)



-- Helpers


fromString : (String -> Maybe a) -> Maybe a -> String -> Maybe a
fromString parse currentValue input =
    if String.isEmpty input then
        Nothing

    else
        parse input
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
        |> when disabled (Background.color gray)


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
    Maybe.map (toAttribute >> (\attr -> attr :: attrs)) maybeValue
        |> Maybe.withDefault attrs


withHtmlAttribute :
    (a -> Html.Attribute msg)
    -> Maybe a
    -> List (Attribute msg)
    -> List (Attribute msg)
withHtmlAttribute toAttribute maybeValue attrs =
    Maybe.map (toAttribute >> htmlAttribute >> (\attr -> attr :: attrs)) maybeValue
        |> Maybe.withDefault attrs



-- Style


red : Color
red =
    rgb255 255 0 0


gray : Color
gray =
    rgb255 204 204 204


white : Color
white =
    rgb 1 1 1


black : Color
black =
    rgb 0 0 0


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
        [ Background.color (rgb255 52 73 94)
        , Font.color white
        , mouseOver [ Background.color (rgb255 32 55 77) ]
        ]
    , disabledColors =
        [ Background.color gray
        , Font.color (rgb255 136 136 136)
        ]
    }
