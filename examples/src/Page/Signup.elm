module Page.Signup exposing (Model, Msg, init, update, view)

import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Data.User as User exposing (User)
import Form exposing (Form)
import Form.View
import Html exposing (Html)
import Task
import View


type Model
    = FillingForm (Form.View.Model Values)
    | SignedUp User


type alias Values =
    { email : String
    , name : String
    , password : String
    , repeatPassword : String
    , favoriteLanguage : String
    , acceptTerms : Bool
    , errors : Errors
    }


type alias Errors =
    { email : Maybe Error }


type alias Error =
    { value : String, error : String }


type Msg
    = FormChanged (Form.View.Model Values)
    | SignUp EmailAddress User.Name User.Password User.FavoriteLanguage
    | SignupAttempted (Result String User)


init : Model
init =
    { email = ""
    , name = ""
    , password = ""
    , repeatPassword = ""
    , favoriteLanguage = ""
    , acceptTerms = False
    , errors = { email = Nothing }
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
                FillingForm formModel ->
                    ( FillingForm { formModel | state = Form.View.Loading }
                    , User.signUp email name password favoriteLanguage
                        |> Task.attempt SignupAttempted
                    )

                _ ->
                    ( model, Cmd.none )

        SignupAttempted (Ok user) ->
            ( SignedUp user, Cmd.none )

        SignupAttempted (Err error) ->
            case model of
                FillingForm formModel ->
                    let
                        values =
                            formModel.values

                        errors =
                            values.errors
                    in
                    ( FillingForm
                        { formModel
                            | state = Form.View.Idle
                            , values =
                                { values
                                    | errors =
                                        { errors
                                            | email = Just (Error values.email error)
                                        }
                                }
                        }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )


view : View.FormView -> Model -> Html Msg
view formView model =
    case model of
        FillingForm formModel ->
            Html.div []
                [ Html.h1 [] [ Html.text "Signup" ]
                , code
                , View.form formView
                    { onChange = FormChanged
                    , action = "Sign up"
                    , loading = "Loading..."
                    , validation = Form.View.ValidateOnSubmit
                    }
                    form
                    formModel
                ]

        SignedUp user ->
            Html.div []
                [ Html.h1 [] [ Html.text "Signup successful!" ]
                , Html.text (Debug.toString user)
                ]


form : Form Values Msg
form =
    let
        emailField =
            Form.emailField
                { parser = EmailAddress.parse
                , value = .email
                , update = \value values -> { values | email = value }
                , error =
                    \{ email, errors } ->
                        if Just email == Maybe.map .value errors.email then
                            Maybe.map .error errors.email

                        else
                            Nothing
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

        repeatPasswordField =
            Form.meta
                (\values ->
                    Form.passwordField
                        { parser =
                            \value ->
                                if value == values.password then
                                    Ok ()

                                else
                                    Err "The passwords do not match"
                        , value = .repeatPassword
                        , update =
                            \newValue values_ ->
                                { values_ | repeatPassword = newValue }
                        , error = always Nothing
                        , attributes =
                            { label = "Repeat password"
                            , placeholder = "Your password again..."
                            }
                        }
                )

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
                , error = always Nothing
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
                , error = always Nothing
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
    Form.succeed
        (\email name password favoriteLanguage _ ->
            SignUp email name password favoriteLanguage
        )
        |> Form.append emailField
        |> Form.append nameField
        |> Form.append
            (Form.succeed (\password _ -> password)
                |> Form.append passwordField
                |> Form.append repeatPasswordField
                |> Form.group
            )
        |> Form.append favoriteLanguageField
        |> Form.append acceptTermsCheckbox


code : Html msg
code =
    View.code
        [ { filename = "Signup.elm"
          , path = "Signup.elm"
          , code = """Form.succeed
    (\\email name password favoriteLanguage _ ->
        SignUp email name password favoriteLanguage
    )
    |> Form.append emailField
    |> Form.append nameField
    |> Form.append
        (Form.succeed (\\password _ -> password)
            |> Form.append passwordField
            |> Form.append repeatPasswordField
            |> Form.group
        )
    |> Form.append favoriteLanguageField
    |> Form.append acceptTermsCheckbox"""
          }
        ]
