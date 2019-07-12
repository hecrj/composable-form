# composable-form [![Build Status](https://travis-ci.org/hecrj/composable-form.svg?branch=master)](https://travis-ci.org/hecrj/composable-form)

This package allows you to build forms that are

  * **Composable**: they can be extended and embedded in other forms.
  * **Type-safe**: everything is safely tied together with compiler guarantees.
  * **Maintainable**: you do not need `view` code nor a `msg` for each form field.
  * **Concise**: field validation and update logic are defined in a single place.
  * **Consistent**: validation errors are always up-to-date with the current field values.
  * **Extensible**: you can create your own custom fields and write custom view code.

Here is an example that defines a login form:

```elm
module Form.Login exposing (Output, Values, form)

import EmailAddress exposing (EmailAddress)
import Form exposing (Form)


type alias Values =
    { email : String
    , password : String
    , rememberMe : Bool
    }


type alias Output =
    { email : EmailAddress
    , password : String
    , rememberMe : Bool
    }


form : Form Values Output
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

        passwordField =
            Form.passwordField
                { parser = Ok
                , value = .password
                , update = \value values -> { values | password = value }
                , error = always Nothing
                , attributes =
                    { label = "Password"
                    , placeholder = "Your password"
                    }
                }

        rememberMeCheckbox =
            Form.checkboxField
                { parser = Ok
                , value = .rememberMe
                , update = \value values -> { values | rememberMe = value }
                , error = always Nothing
                , attributes =
                    { label = "Remember me" }
                }
    in
    Form.succeed Output
        |> Form.append emailField
        |> Form.append passwordField
        |> Form.append rememberMeCheckbox

```

Read the [`Form` module documentation][form-docs] to understand how this code works.

[form-docs]: http://package.elm-lang.org/packages/hecrj/composable-form/latest/Form
[ellie-example]: https://ellie-app.com/3Q3ydLznQRra1

## Demo / Examples

Try out the [live demo](https://hecrj.github.io/composable-form) and/or
[check out the examples](https://github.com/hecrj/composable-form/tree/master/examples/src/Page).

Also, feel free to play with the package using [this Ellie snippet][ellie-example].

## Contributing / Feedback

Feel free to fork and open issues or pull requests. You can also come to chat in
the #forms channel on the [Elm Slack][elm-slack], feel free to contact me (@hecrj) there!

[elm-slack]: https://elmlang.herokuapp.com
