# composable-form [![Build Status](https://travis-ci.org/hecrj/composable-form.svg?branch=master)](https://travis-ci.org/hecrj/composable-form)

This package allows you to build forms that are

  * **Composable**: they can be extended and embedded in other forms.
  * **Type-safe**: they can produce any kind of type when submitted.
  * **Maintainable**: you do not need `view` code nor a `msg` for each form field.
  * **Concise**: field validation and update logic are defined in a single place.
  * **Consistent**: validation errors are always up-to-date with the current field values.
  * **Extensible**: you can create your own custom fields and custom form renderers.

Here is an example that defines a login form:

```elm
module Form.Login exposing (Output, Values, form)

import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Form exposing (Form)
import Form.Value exposing (Value)


type alias Values =
    { email : Value String
    , password : Value String
    , rememberMe : Value Bool
    }


type alias Output
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

## Demo / Examples

Try out the [live demo](https://hecrj.github.io/composable-form) and/or
[check out the examples](examples/src/Page).

## Contributing / Feedback

Feel free to fork and open issues or pull requests. You can also contact me (@hecrj) on the
[Elm Slack][elm-slack].

[elm-slack]: https://elmlang.herokuapp.com
