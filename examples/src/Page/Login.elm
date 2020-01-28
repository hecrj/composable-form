module Page.Login exposing (Model, Msg, init, update, view)

import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Form exposing (Form)
import Form.View
import Form.View.Ui
import Html exposing (Html)
import View


type alias Model =
    Form.View.Model Values


type alias Values =
    { email : String
    , password : String
    , rememberMe : Bool
    }


type Msg
    = FormChanged Model
    | LogIn EmailAddress String Bool


init : Model
init =
    { email = ""
    , password = ""
    , rememberMe = False
    }
        |> Form.View.idle


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged newModel ->
            newModel

        LogIn email password rememberMe ->
            { model | state = Form.View.Success "You have been logged in successfully" }


view : View.FormView -> Model -> Html Msg
view formView model =
    Html.div []
        [ Html.h1 [] [ Html.text "Login" ]
        , code
        , View.form formView
            { onChange = FormChanged
            , action = "Log in"
            , loading = "Logging in..."
            , validation = Form.View.ValidateOnSubmit
            }
            form
            model
        ]


form : Form Values Msg
form =
    let
        emailField =
            Form.emailField
                { parser = EmailAddress.parse
                , value = .email
                , update = \value values -> { values | email = value }
                , error = always Nothing
                , attributes =
                    { label = "E-Mail"
                    , placeholder = "some@email.com"
                    , htmlAttributes = [ ( "autocomplete", "email" ) ]
                    }
                }

        passwordField =
            Form.passwordField
                { parser = Ok
                , value = .password
                , update = \value values -> { values | password = value }
                , error = always Nothing
                , attributes =
                    { label = "Password"
                    , placeholder = "Your password"
                    , htmlAttributes = [ ( "autocomplete", "current-password" ) ]
                    }
                }

        rememberMeCheckbox =
            Form.checkboxField
                { parser = Ok
                , value = .rememberMe
                , update = \value values -> { values | rememberMe = value }
                , error = always Nothing
                , attributes =
                    { label = "Remember me"
                    , htmlAttributes = []
                    }
                }
    in
    Form.succeed LogIn
        |> Form.append emailField
        |> Form.append passwordField
        |> Form.append rememberMeCheckbox


code : Html msg
code =
    View.code
        [ { filename = "Login.elm"
          , path = "Login.elm"
          , code = """Form.succeed LogIn
    |> Form.append emailField
    |> Form.append passwordField
    |> Form.append rememberMeCheckbox"""
          }
        ]
