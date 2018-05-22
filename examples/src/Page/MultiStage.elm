module Page.MultiStage exposing (Model, Msg, init, update, view)

import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Data.User as User exposing (User)
import Form exposing (Form)
import Form.Value as Value exposing (Value)
import Form.View.MultiStage as MultiStage
import Html exposing (Html)
import Html.Attributes as Attributes
import View


type alias Model =
    MultiStage.Model Values


type alias Values =
    { email : Value String
    , name : Value String
    , password : Value String
    , favoriteLanguage : Value String
    }


type Msg
    = FormChanged (MultiStage.Model Values)
    | SignUp EmailAndName User.Password User.FavoriteLanguage


init : Model
init =
    { email = Value.blank
    , name = Value.blank
    , password = Value.blank
    , favoriteLanguage = Value.blank
    }
        |> MultiStage.idle


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FormChanged newForm ->
            ( newForm, Cmd.none )

        SignUp { email, name } password favoriteLanguage ->
            ( { model | state = MultiStage.Loading }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Multiple stages" ]
        , code
        , MultiStage.view
            { onChange = FormChanged
            , action = "Sign up"
            , loading = "Loading..."
            , next = "Next"
            , back = "Back"
            }
            form
            model
        ]


form : MultiStage.Form Values Msg
form =
    MultiStage.build SignUp
        |> MultiStage.add emailAndNameForm viewEmailAndNameForm
        |> MultiStage.add passwordField viewPassword
        |> MultiStage.end favoriteLanguageField



-- Email and Name


type alias EmailAndName =
    { email : EmailAddress
    , name : User.Name
    }


emailAndNameForm : Form Values EmailAndName
emailAndNameForm =
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
    in
    Form.succeed EmailAndName
        |> Form.append emailField
        |> Form.append nameField


viewEmailAndNameForm : EmailAndName -> Html msg
viewEmailAndNameForm { email, name } =
    Html.div [ Attributes.class "stage" ]
        [ Html.h3 [] [ Html.text (User.nameToString name ++ " (" ++ EmailAddress.toString email ++ ")") ]
        ]



-- Password


passwordField : Form Values User.Password
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


viewPassword : User.Password -> Html msg
viewPassword password =
    Html.div [ Attributes.class "stage" ]
        [ Html.text ("Your password length is: " ++ toString (User.passwordLength password)) ]



-- Favorite language


favoriteLanguageField : Form Values User.FavoriteLanguage
favoriteLanguageField =
    let
        langLabel lang =
            case lang of
                User.Elm ->
                    "Elm"

                User.Javascript ->
                    "Javascript"

                User.Other ->
                    "Other"
    in
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


code : Html msg
code =
    View.code
        [ { filename = "MultiStage.elm"
          , path = "MultiStage.elm"
          , code = """MultiStage.build SignUp
    |> MultiStage.add emailAndNameForm viewEmailAndNameForm
    |> MultiStage.add passwordField viewPassword
    |> MultiStage.end favoriteLanguageField"""
          }
        ]
