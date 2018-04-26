module Page.Signup exposing (Model, Msg, init, update, view)

import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Data.User as User exposing (User)
import Form exposing (Form)
import Form.Value as Value exposing (Value)
import Form.View
import Html exposing (Html)
import Task


type Model
    = FillingForm (Form.View.Model Values)
    | SignedUp User


type alias Values =
    { email : Value String
    , name : Value String
    , password : Value String
    , favoriteLanguage : Value String
    , acceptTerms : Value Bool
    }


type Msg
    = FormChanged (Form.View.Model Values)
    | SignUp EmailAddress User.Name User.Password User.FavoriteLanguage
    | SignupAttempted (Result String User)


init : Model
init =
    { email = Value.blank
    , name = Value.blank
    , password = Value.blank
    , favoriteLanguage = Value.blank
    , acceptTerms = Value.blank
    }
        |> Form.View.idle
        |> FillingForm


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormChanged newForm ->
            case model of
                FillingForm _ ->
                    ( FillingForm newForm, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignUp email name password favoriteLanguage ->
            case model of
                FillingForm form ->
                    ( FillingForm { form | state = Form.View.Loading }
                    , User.signUp email name password favoriteLanguage
                        |> Task.attempt SignupAttempted
                    )

                _ ->
                    ( model, Cmd.none )

        SignupAttempted (Ok user) ->
            ( SignedUp user, Cmd.none )

        SignupAttempted (Err error) ->
            case model of
                FillingForm form ->
                    ( FillingForm { form | state = Form.View.Error error }, Cmd.none )

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    case model of
        FillingForm formModel ->
            Html.div []
                [ Html.h1 [] [ Html.text "Signup" ]
                , Form.View.basic
                    { onChange = FormChanged
                    , action = "Sign up"
                    , loadingMessage = "Loading..."
                    , validation = Form.View.ValidateOnSubmit
                    }
                    form
                    formModel
                ]

        SignedUp user ->
            Html.div []
                [ Html.h1 [] [ Html.text "Signup successful!" ]
                , Html.text (toString user)
                ]


form : Form Values Msg
form =
    let
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

        favoriteLanguageField =
            Form.selectField
                { parser =
                    User.parseFavoriteLanguage
                        >> Result.andThen
                            (\lang ->
                                if lang == User.Javascript then
                                    Err "You didn't choose right :/"
                                else
                                    Ok lang
                            )
                , value = .favoriteLanguage
                , update = \value values -> { values | favoriteLanguage = value }
                , attributes =
                    { label = "Which is your favorite language?"
                    , placeholder = "Choose a language"
                    , options =
                        User.favoriteLanguages
                            |> List.map
                                (\lang ->
                                    ( User.favoriteLanguageToString lang
                                    , langLabel lang
                                    )
                                )
                    }
                }

        acceptTermsCheckbox =
            Form.checkboxField
                { parser =
                    \value ->
                        if value then
                            Ok ()
                        else
                            Err "You must accept the terms"
                , value = .acceptTerms
                , update = \value values -> { values | acceptTerms = value }
                , attributes =
                    { label = "Accept Terms and Conditions" }
                }

        langLabel lang =
            case lang of
                User.Elm ->
                    "Elm"

                User.Javascript ->
                    "Javascript"

                User.Other ->
                    "Other"
    in
    Form.empty SignUp
        |> Form.append emailField
        |> Form.append nameField
        |> Form.append passwordField
        |> Form.append favoriteLanguageField
        |> Form.appendMeta acceptTermsCheckbox
