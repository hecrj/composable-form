module Form.View exposing
    ( Model, State(..), idle
    , ViewConfig, Validation(..)
    , asHtml
    , custom, CustomConfig, FormConfig, TextFieldConfig, NumberFieldConfig, RangeFieldConfig
    , CheckboxFieldConfig, RadioFieldConfig, SelectFieldConfig
    )

{-| This module provides helpers to render a [`Form`](Form#Form).

If you just want to quickly render a [`Form`](Form#Form) as HTML, take a look at
[`asHtml`](#asHtml). If you need more control, use [`custom`](#custom).

**Note:** If you are implementing your own custom fields using [`Form.Base`](Form-Base) then
you cannot use this module. You should use [`Form.Base.fill`](Form-Base#fill) to write
custom view code. Take a look at [the source code of this module][source] for inspiration.

[source]: https://github.com/hecrj/composable-form/blob/1.0.0/src/Form/View.elm


# Model

@docs Model, State, idle


# Configuration

@docs ViewConfig, Validation


# Basic HTML

@docs asHtml


# Custom

@docs custom, CustomConfig, FormConfig, TextFieldConfig, NumberFieldConfig, RangeFieldConfig
@docs CheckboxFieldConfig, RadioFieldConfig, SelectFieldConfig

-}

import Form exposing (Form)
import Form.Base.CheckboxField as CheckboxField
import Form.Base.NumberField as NumberField
import Form.Base.RadioField as RadioField
import Form.Base.RangeField as RangeField
import Form.Base.SelectField as SelectField
import Form.Base.TextField as TextField
import Form.Error as Error exposing (Error)
import Form.Value as Value
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Set exposing (Set)


{-| This type gathers the values of the form, with some exposed state and internal view state that
tracks which fields should show validation errors.
-}
type alias Model values =
    { values : values
    , state : State
    , errorTracking : ErrorTracking
    }


{-| Represents the state of the form.

You can change it at will from your `update` function. For example, you can set the state to
`Loading` if submitting the form fires a remote action, or you can set it to `Error` when
such action fails.

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            FormChanged newModel ->
                ( { newModel | state = FormView.Idle }, Cmd.none )

            SignUp email password ->
                ( { model | state = FormView.Loading }
                , User.signUp email password
                    |> Task.attempt SignupTried
                )

            SignupTried (Ok user) ->
                ( model, Route.navigate (Route.Profile user.slug) )

            SignupTried (Err error) ->
                ( { model | state = FormView.Error error }, Cmd.none )

-}
type State
    = Idle
    | Loading
    | Error String


type ErrorTracking
    = ErrorTracking { showAllErrors : Bool, showFieldError : Set String }


{-| Create a `Model` representing an idle form.

You just need to provide the initial `values` of the form.

-}
idle : values -> Model values
idle values =
    { values = values
    , state = Idle
    , errorTracking =
        ErrorTracking
            { showAllErrors = False
            , showFieldError = Set.empty
            }
    }



-- Configuration


{-| This allows you to configure the view output.

  - `onChange` specifies the message that should be produced when the `Model` changes.
  - `action` is the text of the submit button when the form is not loading.
  - `loading` is the text of the submit button when the form is loading.
  - `validation` lets you choose the validation strategy.

-}
type alias ViewConfig values msg =
    { onChange : Model values -> msg
    , action : String
    , loading : String
    , validation : Validation
    }


{-| The validation strategy.

  - `ValidateOnSubmit` will show field errors only when the user tries to submit an invalid form.
  - `ValidateOnBlur` will show field errors as fields are blurred.

-}
type Validation
    = ValidateOnSubmit
    | ValidateOnBlur



-- Custom


{-| The configuration needed to create a custom view function.

It needs functions to render each of [the supported `Form` fields](Form#fields), a function to
render a [`group`](Form#group) of fields, and a function to wrap the fields together in a `form`.

-}
type alias CustomConfig msg element =
    { form : FormConfig msg element -> element
    , textField : TextFieldConfig msg -> element
    , emailField : TextFieldConfig msg -> element
    , passwordField : TextFieldConfig msg -> element
    , textareaField : TextFieldConfig msg -> element
    , searchField : TextFieldConfig msg -> element
    , numberField : NumberFieldConfig msg -> element
    , rangeField : RangeFieldConfig msg -> element
    , checkboxField : CheckboxFieldConfig msg -> element
    , radioField : RadioFieldConfig msg -> element
    , selectField : SelectFieldConfig msg -> element
    , group : List element -> element
    }


{-| Describes how a form should be rendered.

  - `onSubmit` contains the output of the form if there are no validation errors.
  - `state` is the [`State`](#State) of the form.
  - `action` is the main action of the form, you should probably render this in the submit button.
  - `loading` is the loading message that should be shown when the form is loading.
  - `fields` contains the already rendered fields.

-}
type alias FormConfig msg element =
    { onSubmit : Maybe msg
    , state : State
    , action : String
    , loading : String
    , fields : List element
    }


{-| Describes how a text field should be rendered.

  - `onChange` takes a new value for the field and returns the `msg` that should be produced.
  - `onBlur` might contain a `msg` that should be produced when the field is blurred.
  - `disabled` tells you whether the field should be disabled or not. It is `True` when the form is
    loading.
  - `value` contains the current value of the field.
  - `error` might contain a field [`Error`](Form-Error#Error).
  - `showError` tells you if you should show the `error` for this particular field. Its value
    depends on the [validation strategy](#Validation).
  - `attributes` are [`TextField.Attributes`](Form-Base-TextField#Attributes).

-}
type alias TextFieldConfig msg =
    { onChange : String -> msg
    , onBlur : Maybe msg
    , disabled : Bool
    , value : String
    , error : Maybe Error
    , showError : Bool
    , attributes : TextField.Attributes
    }


{-| Describes how a number field should be rendered.

  - `onChange` accepts a `Maybe` so the field value can be cleared.
  - `value` will be `Nothing` if the field is blank or `Just` a `Float`.
  - `attributes` are [`NumberField.Attributes`](Form-Base-NumberField#Attributes).

The other record fields are described in [`TextFieldConfig`](#TextFieldConfig).

-}
type alias NumberFieldConfig msg =
    { onChange : Maybe Float -> msg
    , onBlur : Maybe msg
    , disabled : Bool
    , value : Maybe Float
    , error : Maybe Error
    , showError : Bool
    , attributes : NumberField.Attributes Float
    }


{-| Describes how a range field should be rendered.

  - `onChange` accepts a `Maybe` so the field value can be cleared.
  - `value` will be `Nothing` if the field is blank or `Just` a `Float`.
  - `attributes` are [`RangeField.Attributes`](Form-Base-RangeField#Attributes).

The other record fields are described in [`TextFieldConfig`](#TextFieldConfig).

-}
type alias RangeFieldConfig msg =
    { onChange : Maybe Float -> msg
    , onBlur : Maybe msg
    , disabled : Bool
    , value : Maybe Float
    , error : Maybe Error
    , showError : Bool
    , attributes : RangeField.Attributes Float
    }


{-| Describes how a checkbox field should be rendered.

This is basically a [`TextFieldConfig`](#TextFieldConfig), but its `attributes` are
[`CheckboxField.Attributes`](Form-Base-CheckboxField#Attributes).

-}
type alias CheckboxFieldConfig msg =
    { onChange : Bool -> msg
    , onBlur : Maybe msg
    , disabled : Bool
    , value : Bool
    , error : Maybe Error
    , showError : Bool
    , attributes : CheckboxField.Attributes
    }


{-| Describes how a radio field should be rendered.

This is basically a [`TextFieldConfig`](#TextFieldConfig), but its `attributes` are
[`RadioField.Attributes`](Form-Base-RadioField#Attributes).

-}
type alias RadioFieldConfig msg =
    { onChange : String -> msg
    , onBlur : Maybe msg
    , disabled : Bool
    , value : String
    , error : Maybe Error
    , showError : Bool
    , attributes : RadioField.Attributes
    }


{-| Describes how a select field should be rendered.

This is basically a [`TextFieldConfig`](#TextFieldConfig), but its `attributes` are
[`SelectField.Attributes`](Form-Base-SelectField#Attributes).

-}
type alias SelectFieldConfig msg =
    { onChange : String -> msg
    , onBlur : Maybe msg
    , disabled : Bool
    , value : String
    , error : Maybe Error
    , showError : Bool
    , attributes : SelectField.Attributes
    }


{-| Create a custom view function.

You need to provide a set of functions to render each field, and a function to
put them all together in a form, see [`CustomConfig`](#CustomConfig).

This can be used to create view functions that are compatible with `style-elements`,
`elm-mdl`, `elm-css`, etc. You could even use it to transform forms into a `String` or `Json.Value`!
Take a look at [the different view modules in the examples directory][view-examples]
as you might find an implementation that works for you.

[view-examples]: https://github.com/hecrj/composable-form/tree/master/examples/src/Form/View

Once you provide a [`CustomConfig`](#CustomConfig), you get a view function that supports
a [`ViewConfig`](#ViewConfig). In fact, [`asHtml`](#asHtml) is implemented using this function!

    asHtml : ViewConfig values msg -> Form values msg -> Model values -> Html msg
    asHtml =
        custom
            { form = form
            , textField = inputField "text"
            , emailField = inputField "email"
            , passwordField = inputField "password"
            , searchField = inputField "search"
            , textareaField = textareaField
            , numberField = numberField
            , rangeField = rangeField
            , checkboxField = checkboxField
            , radioField = radioField
            , selectField = selectField
            , group = group
            }

-}
custom :
    CustomConfig msg element
    -> ViewConfig values msg
    -> Form values msg
    -> Model values
    -> element
custom config { onChange, action, loading, validation } form_ model =
    let
        { fields, result } =
            Form.fill form_ model.values

        errorTracking =
            (\(ErrorTracking e) -> e) model.errorTracking

        onSubmit =
            case result of
                Ok msg ->
                    if model.state == Loading then
                        Nothing

                    else
                        Just msg

                Err _ ->
                    if errorTracking.showAllErrors then
                        Nothing

                    else
                        Just
                            (onChange
                                { model
                                    | errorTracking =
                                        ErrorTracking
                                            { errorTracking | showAllErrors = True }
                                }
                            )

        fieldToElement =
            renderField
                config
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
                    Just
                        (\label ->
                            onChange
                                { model
                                    | errorTracking =
                                        ErrorTracking
                                            { errorTracking
                                                | showFieldError =
                                                    Set.insert label errorTracking.showFieldError
                                            }
                                }
                        )

        showError label =
            errorTracking.showAllErrors || Set.member label errorTracking.showFieldError
    in
    config.form
        { onSubmit = onSubmit
        , action = action
        , loading = loading
        , state = model.state
        , fields = List.map fieldToElement fields
        }


type alias FieldConfig values msg =
    { onChange : values -> msg
    , onBlur : Maybe (String -> msg)
    , disabled : Bool
    , showError : String -> Bool
    }


renderField : CustomConfig msg element -> FieldConfig values msg -> ( Form.Field values, Maybe Error ) -> element
renderField customConfig ({ onChange, onBlur, disabled, showError } as fieldConfig) ( field, maybeError ) =
    let
        blurWhenNotBlank value label =
            if Value.raw value == Nothing then
                Nothing

            else
                Maybe.map (\onBlurEvent -> onBlurEvent label) onBlur
    in
    case field of
        Form.Text type_ { attributes, value, update } ->
            let
                config =
                    { onChange = Just >> update >> onChange
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
                    customConfig.textField config

                Form.TextArea ->
                    customConfig.textareaField config

                Form.TextPassword ->
                    customConfig.passwordField config

                Form.TextEmail ->
                    customConfig.emailField config

                Form.TextSearch ->
                    customConfig.searchField config

        Form.Number { attributes, value, update } ->
            customConfig.numberField
                { onChange = update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Range { attributes, value, update } ->
            customConfig.rangeField
                { onChange = update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Checkbox { attributes, value, update } ->
            customConfig.checkboxField
                { onChange = Just >> update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value |> Maybe.withDefault False
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Radio { attributes, value, update } ->
            customConfig.radioField
                { onChange = Just >> update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value |> Maybe.withDefault ""
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Select { attributes, value, update } ->
            customConfig.selectField
                { onChange = Just >> update >> onChange
                , onBlur = blurWhenNotBlank value attributes.label
                , disabled = disabled
                , value = Value.raw value |> Maybe.withDefault ""
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Group fields ->
            customConfig.group (List.map (renderField customConfig fieldConfig) fields)



-- Basic HTML


{-| Render a form as HTML!

You could use it like this:

    FormView.asHtml
        { onChange = FormChanged
        , action = "Log in"
        , loading = "Logging in..."
        , validation = FormView.ValidateOnSubmit
        }
        loginForm
        model

And here is an example of the produced HTML:

```html
<form class="elm-form">
   <div class="elm-form-field">
       <label>E-Mail</label>
       <input type="email" value="some@value.com" placeholder="Type your e-mail...">
   </div>
   <div class="elm-form-field elm-form-field-error">
       <label>Password</label>
       <input type="password" value="" placeholder="Type your password...">
       <div class="elm-form-error">This field is required</div>
   </div>
   <button type="submit">Log in</button>
</form>
```

You can use the different CSS classes to style your forms as you please.

If you need more control over the produced HTML, use [`custom`](#custom).

-}
asHtml : ViewConfig values msg -> Form values msg -> Model values -> Html msg
asHtml =
    custom
        { form = form
        , textField = inputField "text"
        , emailField = inputField "email"
        , passwordField = inputField "password"
        , searchField = inputField "search"
        , textareaField = textareaField
        , numberField = numberField
        , rangeField = rangeField
        , checkboxField = checkboxField
        , radioField = radioField
        , selectField = selectField
        , group = group
        }


form : FormConfig msg (Html msg) -> Html msg
form { onSubmit, action, loading, state, fields } =
    let
        onSubmitEvent =
            onSubmit
                |> Maybe.map (Events.onSubmit >> List.singleton)
                |> Maybe.withDefault []
    in
    Html.form (Attributes.class "elm-form" :: onSubmitEvent)
        (List.concat
            [ fields
            , [ case state of
                    Error error ->
                        errorMessage error

                    _ ->
                        Html.text ""
              , Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (onSubmit == Nothing)
                    ]
                    [ if state == Loading then
                        Html.text loading

                      else
                        Html.text action
                    ]
              ]
            ]
        )


inputField : String -> TextFieldConfig msg -> Html msg
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


textareaField : TextFieldConfig msg -> Html msg
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


numberField : NumberFieldConfig msg -> Html msg
numberField { onChange, onBlur, disabled, value, error, showError, attributes } =
    Html.input
        ([ Events.onInput (fromString String.toFloat value >> onChange)
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


rangeField : RangeFieldConfig msg -> Html msg
rangeField { onChange, onBlur, disabled, value, error, showError, attributes } =
    Html.div
        [ Attributes.class "elm-form-range-field" ]
        [ Html.input
            ([ Events.onInput (fromString String.toFloat value >> onChange)
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
        , Html.span [] [ Html.text (value |> Maybe.map String.fromFloat |> Maybe.withDefault "") ]
        ]
        |> withLabelAndError attributes.label showError error


checkboxField : CheckboxFieldConfig msg -> Html msg
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


radioField : RadioFieldConfig msg -> Html msg
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


selectField : SelectFieldConfig msg -> Html msg
selectField { onChange, onBlur, disabled, value, error, showError, attributes } =
    let
        toOption ( key, label_ ) =
            Html.option
                [ Attributes.value key
                , Attributes.selected (value == key)
                ]
                [ Html.text label_ ]

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


fromString : (String -> Maybe a) -> Maybe a -> String -> Maybe a
fromString parse currentValue input =
    if String.isEmpty input then
        Nothing

    else
        parse input
            |> Maybe.map Just
            |> Maybe.withDefault currentValue
