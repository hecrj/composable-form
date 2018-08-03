module Page.VariableForm exposing (Model, Msg, init, update, view)

import Array exposing (Array)
import Data.User as User
import Form exposing (Form)
import Form.Value as Value exposing (Value)
import Form.View
import Html exposing (Html)
import View


type alias Model =
    Form.View.Model Values


type alias Values =
    { name : Value String
    , websites : Array WebsiteValues
    }


type Msg
    = FormChanged Model
    | Submit User.Name (List Website)


init : Model
init =
    { name = Value.blank
    , websites =
        Array.empty
            |> Array.push
                { name = Value.filled "Elm"
                , address = Value.filled "http://elm-lang.org/"
                }
    }
        |> Form.View.idle


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged newModel ->
            newModel

        Submit name websites ->
            { model | state = Form.View.Loading }


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Variable form" ]
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
        nameField =
            Form.textField
                { parser = User.parseName
                , value = .name
                , update = \value values -> { values | name = value }
                , attributes =
                    { label = "Your name"
                    , placeholder = "Type your name"
                    }
                }
    in
    Form.succeed Submit
        |> Form.append nameField
        |> Form.append
            (Form.variable
                { blank =
                    { name = Value.blank
                    , address = Value.filled "https://"
                    }
                , value = .websites
                , update = \value values -> { values | websites = value }
                , attributes =
                    { add = "Add website"
                    , delete = ""
                    }
                }
                websiteForm
            )


type alias WebsiteValues =
    { name : Value String
    , address : Value String
    }


type alias Website =
    { name : String
    , address : String
    }


websiteForm : Form WebsiteValues Website
websiteForm =
    let
        nameField =
            Form.textField
                { parser = Ok
                , value = .name
                , update = \value values -> { values | name = value }
                , attributes =
                    { label = "Website name"
                    , placeholder = ""
                    }
                }

        addressField =
            Form.textField
                { parser = Ok
                , value = .address
                , update = \value values -> { values | address = value }
                , attributes =
                    { label = "Website address"
                    , placeholder = "https://..."
                    }
                }
    in
    Form.succeed Website
        |> Form.append nameField
        |> Form.append addressField


code : Html msg
code =
    View.code
        [ { filename = "VariableForm.elm"
          , path = "VariableForm.elm"
          , code = """Form.succeed Submit
    |> Form.append nameField
    |> Form.append
        (Form.variable
            { blank =
                { name = Value.blank
                , address = Value.filled "https://"
                }
            , value = .websites
            , update = \\value values -> { values | websites = value }
            , attributes =
                { add = "Add website"
                , delete = ""
                }
            }
            websiteForm
        )"""
          }
        ]
