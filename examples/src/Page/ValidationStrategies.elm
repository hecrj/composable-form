module Page.ValidationStrategies exposing (Model, Msg, init, update, view)

import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Data.User as User exposing (User)
import Form exposing (Form)
import Form.View
import Html exposing (Html)
import View


type alias Model =
    Form.View.Model Values


type alias Values =
    { validationStrategy : String
    , email : String
    , name : String
    , password : String
    }


type Msg
    = FormChanged (Form.View.Model Values)
    | Submit EmailAddress User.Name User.Password


init : Model
init =
    { validationStrategy = "onSubmit"
    , email = ""
    , name = ""
    , password = ""
    }
        |> Form.View.idle


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged newForm ->
            newForm

        Submit email name password ->
            { model | state = Form.View.Loading }


view : View.FormView -> Model -> Html Msg
view formView model =
    Html.div []
        [ Html.h1 [] [ Html.text "Validation strategies" ]
        , code
        , View.form formView
            { onChange = FormChanged
            , action = "Submit"
            , loading = "Loading..."
            , validation =
                if model.values.validationStrategy == "onBlur" then
                    Form.View.ValidateOnBlur

                else
                    Form.View.ValidateOnSubmit
            }
            form
            model
        ]


form : Form Values Msg
form =
    let
        validationStrategyField =
            Form.radioField
                { parser = Ok
                , value = .validationStrategy
                , update = \value values -> { values | validationStrategy = value }
                , error = always Nothing
                , attributes =
                    { label = "Validation strategy"
                    , options =
                        [ Form.View.ValidateOnSubmit, Form.View.ValidateOnBlur ]
                            |> List.map strategyToOption
                    }
                }

        strategyToOption strategy =
            case strategy of
                Form.View.ValidateOnSubmit ->
                    ( "onSubmit", "Validate on form submit" )

                Form.View.ValidateOnBlur ->
                    ( "onBlur", "Validate on field blur" )

        emailField =
            Form.emailField
                { parser = EmailAddress.parse
                , value = .email
                , update = \value values -> { values | email = value }
                , error = always Nothing
                , attributes =
                    { label = "E-Mail"
                    , placeholder = "some@email.com"
                    }
                }

        nameField =
            Form.textField
                { parser = User.parseName
                , value = .name
                , update = \value values -> { values | name = value }
                , error = always Nothing
                , attributes =
                    { label = "Name"
                    , placeholder = "Your name"
                    }
                }

        passwordField =
            Form.passwordField
                { parser = User.parsePassword
                , value = .password
                , update = \value values -> { values | password = value }
                , error = always Nothing
                , attributes =
                    { label = "Password"
                    , placeholder = "Your password"
                    }
                }
    in
    Form.succeed (always Submit)
        |> Form.append validationStrategyField
        |> Form.append emailField
        |> Form.append nameField
        |> Form.append passwordField


code : Html msg
code =
    View.code
        [ { filename = "ValidationStrategies.elm"
          , path = "ValidationStrategies.elm"
          , code = """Form.View.asHtml
    { onChange = FormChanged
    , action = "Submit"
    , loading = "Loading..."
    , validation =
        if onBlurSelected model.values then
            Form.View.ValidateOnBlur
        else
            Form.View.ValidateOnSubmit
    }
    form
    model"""
          }
        ]
