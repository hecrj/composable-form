module Page.Composability.Simple exposing (Model, Msg, init, update, view)

import Data.Address exposing (Address)
import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Data.User as User
import Form exposing (Form)
import Form.View
import Html exposing (Html)
import Page.Composability.Simple.AddressForm as AddressForm
import View


type alias Model =
    Form.View.Model Values


type alias Values =
    { email : String
    , name : String
    , address : AddressForm.Values
    }


type Msg
    = FormChanged (Form.View.Model Values)
    | Submit EmailAddress User.Name Address


init : Model
init =
    { email = ""
    , name = ""
    , address = AddressForm.blank
    }
        |> Form.View.idle


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged newForm ->
            newForm

        Submit email name address ->
            { model | state = Form.View.Loading }


view : View.FormView -> Model -> Html Msg
view formView model =
    Html.div []
        [ Html.h1 [] [ Html.text "Composability" ]
        , code
        , View.form formView
            { onChange = FormChanged
            , action = "Submit"
            , loading = "Loading..."
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
    in
    Form.succeed Submit
        |> Form.append emailField
        |> Form.append nameField
        |> Form.append
            (Form.mapValues
                { value = .address
                , update = \value values -> { values | address = value }
                }
                AddressForm.form
            )


code : Html msg
code =
    View.code
        [ { filename = "AddressForm.elm"
          , path = "Composability/Simple/AddressForm.elm"
          , code = """Form.succeed Address
    |> Form.append countryField
    |> Form.append cityField
    |> Form.append postalCodeField"""
          }
        , { filename = "Composability.elm"
          , path = "Composability/Simple.elm"
          , code = """Form.succeed Submit
    |> Form.append emailField
    |> Form.append nameField
    |> Form.append
        (Form.mapValues
            { value = .address
            , update = \\value values -> { values | address = value }
            }
            AddressForm.form
        )"""
          }
        ]
