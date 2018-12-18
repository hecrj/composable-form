module Page.FormList exposing (Model, Msg, init, update, view)

import Data.User as User
import Form exposing (Form)
import Form.View
import Html exposing (Html)
import View


type alias Model =
    Form.View.Model Values


type alias Values =
    { name : String
    , websites : List WebsiteValues
    }


type Msg
    = FormChanged Model
    | Submit User.Name (List Website)


init : Model
init =
    { name = ""
    , websites =
        [ { name = "Elm"
          , address = "https://elm-lang.org/"
          }
        ]
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
            (Form.list
                { default =
                    { name = ""
                    , address = "https://"
                    }
                , value = .websites
                , update = \value values -> { values | websites = value }
                , attributes =
                    { add = Just "Add website"
                    , delete = Just ""
                    }
                }
                websiteForm
            )


type alias WebsiteValues =
    { name : String
    , address : String
    }


type alias Website =
    { name : String
    , address : String
    }


websiteForm : Int -> Form WebsiteValues Website
websiteForm index =
    let
        nameField =
            Form.textField
                { parser = Ok
                , value = .name
                , update = \value values -> { values | name = value }
                , attributes =
                    { label = "Name of website #" ++ String.fromInt (index + 1)
                    , placeholder = ""
                    }
                }

        addressField =
            Form.textField
                { parser = Ok
                , value = .address
                , update = \value values -> { values | address = value }
                , attributes =
                    { label = "Address of website #" ++ String.fromInt (index + 1)
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
