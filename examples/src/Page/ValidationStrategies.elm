module Page.ValidationStrategies exposing (Model, Msg, init, update, view)

import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Data.User as User exposing (User)
import Form exposing (Form)
import Form.Value as Value exposing (Value)
import Form.View
import Html exposing (Html)


type alias Model =
    Form.View.Model Values


type alias Values =
    { validationStrategy : Value String
    , email : Value String
    , name : Value String
    , password : Value String
    }


type Msg
    = FormChanged (Form.View.Model Values)
    | Submit EmailAddress User.Name User.Password


init : Model
init =
    { validationStrategy = Value.clean "onSubmit"
    , email = Value.blank
    , name = Value.blank
    , password = Value.blank
    }
        |> Form.View.idle


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged newForm ->
            newForm

        Submit email name password ->
            { model | state = Form.View.Loading }


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Validation strategies" ]
        , Form.View.basic
            { onChange = FormChanged
            , action = "Submit"
            , loadingMessage = "Loading..."
            , validation =
                if Value.raw model.values.validationStrategy == Just "onBlur" then
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
            Form.selectField
                { parser = Ok
                , value = .validationStrategy
                , update = \value values -> { values | validationStrategy = value }
                , attributes =
                    { label = "Validation strategy"
                    , placeholder = "Choose a strategy"
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
                , attributes =
                    { label = "Password"
                    , placeholder = "Your password"
                    }
                }
    in
    Form.empty Submit
        |> Form.appendMeta validationStrategyField
        |> Form.append emailField
        |> Form.append nameField
        |> Form.append passwordField
