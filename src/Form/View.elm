module Form.View
    exposing
        ( CheckboxFieldConfig
        , CustomConfig
        , FormConfig
        , Model
        , SelectFieldConfig
        , State(..)
        , TextFieldConfig
        , Validation(..)
        , ViewConfig
        , asHtml
        , custom
        , idle
        )

{-| This module provides helpers to render a [`Form`](Form#Form).

If you just want to quickly render a [`Form`](Form#Form) as HTML, take a look at
[`asHtml`](#asHtml). If you need more control, use [`custom`](#custom).

**Note:** If you are implementing your own custom fields using [`Form.Base`](Form-Base) then
you cannot use this module. You should use [`Form.Base.fill`](Form-Base#fill) to write your
own renderer. Take a look at [the source code of this module][source] for inspiration.

[source]: https://github.com/hecrj/composable-form/tree/master/src/Form/View.elm


# Model

@docs Model, State, idle


# Configuration

@docs ViewConfig, Validation


# Built-in HTML renderer

@docs asHtml


# Custom renderer

@docs custom, CustomConfig, FormConfig, TextFieldConfig, CheckboxFieldConfig, SelectFieldConfig

-}

import Form exposing (Form)
import Form.Base.CheckboxField as CheckboxField
import Form.Base.SelectField as SelectField
import Form.Base.TextField as TextField
import Form.Error as Error exposing (Error)
import Form.Field.Value as Value
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Set exposing (Set)


{-| This type gathers the values of the form, with some exposed state and internal view state.
-}
type alias Model values =
    { values : values
    , state : State
    , internal : Internal
    }


{-| Represents the state of the form.

You can change it at will from your `update` function. For example, you can set the state to
`Loading` when submitting the form fires a remote action, or you can set it to `Error` when
such action fails.

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            FormChanged newModel ->
                ( Form.Idle, Cmd.none )

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


type Internal
    = Internal { showAllErrors : Bool, showFieldError : Set String }


{-| Create a `Model` representing an idle form.

You just need to provide the initial `values` of the form.

-}
idle : values -> Model values
idle values =
    { values = values
    , state = Idle
    , internal =
        Internal
            { showAllErrors = False
            , showFieldError = Set.empty
            }
    }



-- Configuration


{-| This type allows you to configure the renderer behavior.

  - `onChange` specifies the message that should be thrown when the `Model` changes.
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



-- Custom renderer


{-| The configuration needed to create a custom renderer.

It needs functions to render each of [the supported `Form` fields](Form#fields), and a function
`form` to wrap the fields together in a form.

-}
type alias CustomConfig msg element =
    { form : FormConfig msg element -> element
    , textField : TextFieldConfig msg -> element
    , emailField : TextFieldConfig msg -> element
    , passwordField : TextFieldConfig msg -> element
    , textareaField : TextFieldConfig msg -> element
    , checkboxField : CheckboxFieldConfig msg -> element
    , selectField : SelectFieldConfig msg -> element
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

  - `onInput` takes a new value for the field and returns the `msg` that should be produced.
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
    { onInput : String -> msg
    , onBlur : Maybe msg
    , disabled : Bool
    , value : String
    , error : Maybe Error
    , showError : Bool
    , attributes : TextField.Attributes
    }


{-| Describes how a checkbox field should be rendered.

  - `onCheck` takes a new value for the checkbox and returns the `msg` that should be produced.
  - `checked` tells you whether the checkbox should be checked or not.
  - `attributes` are [`CheckboxField.Attributes`](Form-Base-CheckboxField#Attributes).

The other record fields are described in [`TextFieldConfig`](#TextFieldConfig).

-}
type alias CheckboxFieldConfig msg =
    { onCheck : Bool -> msg
    , disabled : Bool
    , checked : Bool
    , error : Maybe Error
    , showError : Bool
    , attributes : CheckboxField.Attributes
    }


{-| Describes how a select field should be rendered.

This is basically a [`TextFieldConfig`](#TextFieldConfig), but its `attributes` are
[`SelectField.Attributes`](Form-Base-SelectField#Attributes).

-}
type alias SelectFieldConfig msg =
    { onInput : String -> msg
    , onBlur : Maybe msg
    , disabled : Bool
    , value : String
    , error : Maybe Error
    , showError : Bool
    , attributes : SelectField.Attributes
    }


{-| Create a custom renderer.

You need to provide a set of functions to render each field, and a function to
put them all together in a form, see [`CustomConfig`](#CustomConfig).

This function can be used to create form renderers that are compatible with `style-elements`,
`elm-mdl`, `elm-css`, etc. You could even use it to transform forms into a `String` or `Json.Value`!

Once you provide a [`CustomConfig`](#CustomConfig) this function returns a renderer that supports
a [`ViewConfig`](#ViewConfig). In fact, [`asHtml`](#asHtml) is implemented using this function!

    asHtml : ViewConfig values msg -> Form values msg -> Model values -> Html msg
    asHtml =
        custom
            { form = form
            , textField = inputField "text"
            , emailField = inputField "email"
            , passwordField = inputField "password"
            , textareaField = textareaField
            , checkboxField = checkboxField
            , selectField = selectField
            }

-}
custom : CustomConfig msg element -> ViewConfig values msg -> Form values msg -> Model values -> element
custom config { onChange, action, loading, validation } form model =
    let
        { fields, result } =
            Form.fill form model.values

        internal =
            case model.internal of
                Internal internal ->
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
                                    | internal = Internal { internal | showAllErrors = True }
                                }
                            )

        fieldToElement =
            field
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
                                    | internal =
                                        Internal
                                            { internal
                                                | showFieldError =
                                                    Set.insert label internal.showFieldError
                                            }
                                }
                        )

        showError label =
            internal.showAllErrors || Set.member label internal.showFieldError
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


field : CustomConfig msg element -> FieldConfig values msg -> ( Form.Field values, Maybe Error ) -> element
field customConfig { onChange, onBlur, disabled, showError } ( field, maybeError ) =
    let
        blurWhenNotBlank value label =
            if Value.raw value == Nothing then
                Nothing
            else
                Maybe.map (\onBlur -> onBlur label) onBlur
    in
    case field of
        Form.Text type_ { attributes, state } ->
            let
                config =
                    { onInput = state.update >> onChange
                    , onBlur = blurWhenNotBlank state.value attributes.label
                    , disabled = disabled
                    , value = Value.raw state.value |> Maybe.withDefault ""
                    , error = maybeError
                    , showError = showError attributes.label
                    , attributes = attributes
                    }
            in
            case type_ of
                TextField.Raw ->
                    customConfig.textField config

                TextField.Textarea ->
                    customConfig.textareaField config

                TextField.Password ->
                    customConfig.passwordField config

                TextField.Email ->
                    customConfig.emailField config

        Form.Checkbox { attributes, state } ->
            customConfig.checkboxField
                { checked = Value.raw state.value |> Maybe.withDefault False
                , disabled = disabled
                , onCheck = state.update >> onChange
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }

        Form.Select { attributes, state } ->
            customConfig.selectField
                { onInput = state.update >> onChange
                , onBlur = blurWhenNotBlank state.value attributes.label
                , disabled = disabled
                , value = Value.raw state.value |> Maybe.withDefault ""
                , error = maybeError
                , showError = showError attributes.label
                , attributes = attributes
                }



-- Built-in HTML renderer


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
        , textareaField = textareaField
        , checkboxField = checkboxField
        , selectField = selectField
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
inputField type_ { onInput, onBlur, disabled, value, error, showError, attributes } =
    let
        fixedAttributes =
            [ Events.onInput onInput
            , Attributes.disabled disabled
            , Attributes.value value
            , Attributes.placeholder attributes.placeholder
            , Attributes.type_ type_
            ]

        inputAttributes =
            Maybe.map (Events.onBlur >> flip (::) fixedAttributes) onBlur
                |> Maybe.withDefault fixedAttributes
    in
    Html.div
        [ Attributes.classList
            [ ( "elm-form-field", True )
            , ( "elm-form-field-error", error /= Nothing )
            ]
        ]
        [ fieldLabel attributes.label
        , Html.input inputAttributes
            []
        , maybeErrorMessage showError error
        ]


textareaField : TextFieldConfig msg -> Html msg
textareaField { onInput, disabled, value, error, showError, attributes } =
    Html.div [ Attributes.class "elm-form-field" ]
        [ fieldLabel attributes.label
        , Html.textarea
            [ Events.onInput onInput
            , Attributes.disabled disabled
            , Attributes.placeholder attributes.placeholder
            ]
            [ Html.text value ]
        , maybeErrorMessage showError error
        ]


checkboxField : CheckboxFieldConfig msg -> Html msg
checkboxField { checked, disabled, onCheck, error, showError, attributes } =
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
            , Html.text attributes.label
            ]
        , maybeErrorMessage showError error
        ]


selectField : SelectFieldConfig msg -> Html msg
selectField { onInput, onBlur, disabled, value, error, showError, attributes } =
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

        fixedAttributes =
            [ Events.onInput onInput
            , Attributes.disabled disabled
            ]

        selectAttributes =
            Maybe.map (Events.onBlur >> flip (::) fixedAttributes) onBlur
                |> Maybe.withDefault fixedAttributes
    in
    Html.div
        [ Attributes.classList
            [ ( "elm-form-field", True )
            , ( "elm-form-field-error", error /= Nothing )
            ]
        ]
        [ fieldLabel attributes.label
        , Html.select selectAttributes
            (placeholderOption :: List.map toOption attributes.options)
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
