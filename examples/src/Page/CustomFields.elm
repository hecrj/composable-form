module Page.CustomFields exposing (Model, Msg, init, update, view)

import Data.User as User
import Html exposing (Html)
import Page.CustomFields.ComplexValidationField as ComplexValidationField
import Page.CustomFields.Form as Form exposing (Form)
import Page.CustomFields.Form.View as FormView
import View


type alias Model =
    FormView.Model Values


type alias Values =
    { email : ComplexValidationField.State String User.ValidEmail
    }


type Msg
    = EmailMsg (ComplexValidationField.Msg String User.ValidEmail)
    | FormChanged Model
    | Submit User.ValidEmail


init : Model
init =
    { email = ComplexValidationField.init ""
    }
        |> FormView.idle


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EmailMsg emailMsg ->
            let
                values =
                    model.values
            in
            ComplexValidationField.update User.validateEmailAddress emailMsg values.email
                |> Tuple.mapFirst (\state -> { model | values = { values | email = state } })
                |> Tuple.mapSecond (Cmd.map EmailMsg)

        FormChanged newModel ->
            ( newModel, Cmd.none )

        Submit email ->
            ( { model | state = FormView.Loading }, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Custom fields" ]
        , code
        , FormView.asHtml
            { onChange = FormChanged
            , action = "Submit"
            , loading = "Loading"
            }
            form
            model
        ]


form : Form Values Msg Msg
form =
    let
        emailField =
            Form.customEmailField
                { onChange = EmailMsg
                , state = .email
                , attributes =
                    { label = "Server-side validated e-mail"
                    , placeholder = "some@email.com"
                    , htmlAttributes = []
                    }
                }
    in
    Form.succeed Submit
        |> Form.append emailField


code : Html msg
code =
    View.code
        [ { filename = "CustomFields.elm"
          , path = "CustomFields.elm"
          , code = """let
    emailField =
        Form.customEmailField
            { onChange = EmailMsg
            , state = .email
            , attributes =
                { label = "Server-side validated e-mail"
                , placeholder = "some@email.com"
                }
            }
in
Form.succeed Submit
    |> Form.append emailField"""
          }
        ]
