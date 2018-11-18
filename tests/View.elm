module View exposing (optionalGroup)

import Expect exposing (Expectation)
import Form exposing (Form)
import Form.Error as Error
import Form.View as View
import Test exposing (..)



-- Optional group


optionalGroup : Test
optionalGroup =
    let
        form =
            Form.succeed (\_ _ -> ())
                |> Form.append nameField
                |> Form.append surnameField
                |> Form.group
                |> Form.optional

        view =
            View.custom
                { form = \{ fields } -> String.join "|" fields
                , textField = \{ error } -> errorToString error
                , emailField = \_ -> ""
                , passwordField = \_ -> ""
                , textareaField = \_ -> ""
                , searchField = \_ -> ""
                , numberField = \_ -> ""
                , rangeField = \_ -> ""
                , checkboxField = \_ -> ""
                , radioField = \_ -> ""
                , selectField = \_ -> ""
                , group = \fields -> String.join "|" fields
                , section = \_ _ -> ""
                }

        errorToString maybeError =
            case maybeError of
                Just Error.RequiredFieldIsEmpty ->
                    "Required field is empty"

                Just (Error.ValidationFailed validationError) ->
                    validationError

                Nothing ->
                    ""
    in
    describe "Form.View optional group"
        [ describe "when empty"
            [ test "does not render errors" <|
                \_ ->
                    view
                        { onChange = \_ -> Nothing
                        , action = "Submit"
                        , loading = "Submitting..."
                        , validation = View.ValidateOnSubmit
                        }
                        form
                        (View.idle { name = "", surname = "" })
                        |> Expect.equal "|"
            ]
        , describe "when partially filled"
            [ test "does render errors" <|
                \_ ->
                    view
                        { onChange = \_ -> Nothing
                        , action = "Submit"
                        , loading = "Submitting..."
                        , validation = View.ValidateOnSubmit
                        }
                        form
                        (View.idle { name = "H", surname = "" })
                        |> Expect.equal "|Required field is empty"
            ]
        ]


nameField : Form { r | name : String } String
nameField =
    Form.textField
        { parser = Ok
        , value = .name
        , update = \value values -> { values | name = value }
        , attributes =
            { label = "Name"
            , placeholder = "Type your name..."
            }
        }


surnameField : Form { r | surname : String } String
surnameField =
    Form.textField
        { parser = Ok
        , value = .surname
        , update = \value values -> { values | surname = value }
        , attributes =
            { label = "Surname"
            , placeholder = "Type your surname..."
            }
        }
