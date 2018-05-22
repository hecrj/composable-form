module Page.Composability.WithExtensibleRecords exposing (Model, Msg, init, update, view)

import Data.Address exposing (Address)
import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Data.User as User
import Form exposing (Form)
import Form.Value as Value exposing (Value)
import Form.View
import Html exposing (Html)
import Page.Composability.WithExtensibleRecords.AddressForm as AddressForm exposing (AddressForm)
import View


type alias Model =
    Form.View.Model Values


type alias Values =
    { email : Value String
    , name : Value String
    , address : AddressForm.Values
    }


type Msg
    = FormChanged (Form.View.Model Values)
    | Submit EmailAddress User.Name Address


init : Model
init =
    { email = Value.blank
    , name = Value.blank
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


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Composability" ]
        , code
        , Form.View.asHtml
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
    Form.succeed Submit
        |> Form.append emailField
        |> Form.append nameField
        |> Form.append AddressForm.form


code : Html msg
code =
    View.code
        [ { filename = "AddressForm.elm"
          , path = "Composability/WithExtensibleRecords/AddressForm.elm"
          , code = """Form.succeed Address
    |> Form.append countryField
    |> Form.append cityField
    |> Form.append postalCodeField"""
          }
        , { filename = "Composability.elm"
          , path = "Composability/WithExtensibleRecords.elm"
          , code = """Form.succeed Submit
    |> Form.append emailField
    |> Form.append nameField
    |> Form.append AddressForm.form"""
          }
        ]
