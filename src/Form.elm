module Form
    exposing
        ( Field(..)
        , Form
        , append
        , checkboxField
        , emailField
        , fill
        , optional
        , passwordField
        , selectField
        , succeed
        , textField
        , textareaField
        )

{-| This module helps you build [composable forms](#Form) made of [simple fields](#simple-fields).


# Definition

@docs Form


# Simple fields

@docs textField, emailField, passwordField, textareaField, checkboxField, selectField


# Composition

All the functions in [the previous section](#simple-fields) produce a `Form` with a **single**
field. You might then be wondering... "How do I create a `Form` with multiple fields?!"
Remember the name of this package: `composable-form`! A `Form` is composable! This section
explains how you can combine different forms into bigger and more complex ones.

@docs succeed, append, optional


# Output

This section describes how to fill a `Form` with its `values` and obtain its
different fields and its `output`. This is mostly used to build custom form renderers.

If you just want to render a simple form as `Html`, check [`Form.View`](Form-View) first as it
might suit your needs just well.

@docs Field, fill

-}

import Form.Base as Base
import Form.Base.CheckboxField as CheckboxField exposing (CheckboxField)
import Form.Base.SelectField as SelectField exposing (SelectField)
import Form.Base.TextField as TextField exposing (TextField)
import Form.Error exposing (Error)
import Form.Value exposing (Value)


-- Definition


{-| A `Form` represents one or more fields. A `Form` can be filled with some `values`,
producing some `output` when validation succeeds.

For example, a `Form String EmailAddress` is a form that is filled with a `String` and produces
an `EmailAddress` if validation succeeds. This form could very well be an
[`emailField`](#emailField)!

-}
type alias Form values output =
    Base.Form values output (Field values)



-- Fields


{-| Create a form that contains a single text field.

It requires some configuration:

  - `parser` specifies how to validate the field. It needs a function that processes the value of
    the field and produces either:
      - a `String` describing an error
      - a correct `output`
  - `value` describes how to obtain the field [`Value`](Form-Value) from the form `values`
  - `update` describes how the current form `values` should be updated with a new field
    [`Value`](Form-Value)
  - `attributes` let you define the specific attributes of the field (`label` and `placeholder`
    in this case, see [`TextField.Attributes`](Form-Field-TextField#Attributes))

It might seem like a lot of configuration... But, don't be scared! In practice, it isn't!
For instance, you could use this function to build a `nameField` that only succeeds when the
inputted name has at least 2 characters, like this:

    nameField : Form { r | name : Value String } String
    nameField =
        Form.textField
            { parser =
                \name ->
                    if String.length name < 2 then
                        Err "the name must have at least 2 characters"
                    else
                        Ok name
            , value = .name
            , update =
                \newValue values ->
                    { values | name = newValue }
            , attributes =
                { label = "Name"
                , placeholder = "Type your name..."
                }
            }

As you can see:

  - a `parser` is just a simple validation function
  - you can define `value` using [record accessors](http://elm-lang.org/docs/records#access)
  - the `update` function updates the `values` of the form with the `newValue`
  - `attributes` are most of the time a simple record

-}
textField :
    { parser : String -> Result String output
    , value : values -> Value String
    , update : Value String -> values -> values
    , attributes : TextField.Attributes
    }
    -> Form values output
textField =
    TextField.form (Text TextField.Raw)


{-| Create a form that contains a single email field.

It has the same configuration options as [`textField`](#textField).

-}
emailField :
    { parser : String -> Result String output
    , value : values -> Value String
    , update : Value String -> values -> values
    , attributes : TextField.Attributes
    }
    -> Form values output
emailField =
    TextField.form (Text TextField.Email)


{-| Create a form that contains a single password field.

It has the same configuration options as [`textField`](#textField).

-}
passwordField :
    { parser : String -> Result String output
    , value : values -> Value String
    , update : Value String -> values -> values
    , attributes : TextField.Attributes
    }
    -> Form values output
passwordField =
    TextField.form (Text TextField.Password)


{-| Create a form that contains a single textarea field.

It has the same configuration options as [`textField`](#textField).

-}
textareaField :
    { parser : String -> Result String output
    , value : values -> Value String
    , update : Value String -> values -> values
    , attributes : TextField.Attributes
    }
    -> Form values output
textareaField =
    TextField.form (Text TextField.Textarea)


{-| Create a form that contains a single checkbox field.

It has a very similar configuration to [`textField`](#textField), the only differences are:

  - Its value is a `Bool` instead of `String`
  - Its attributes are [`CheckboxField.Attributes`](Form-Field-CheckboxField#Attributes)
    instead of [`TextField.Attributes`](Form-Field-TextField#Attributes).

-}
checkboxField :
    { parser : Bool -> Result String output
    , value : values -> Value Bool
    , update : Value Bool -> values -> values
    , attributes : CheckboxField.Attributes
    }
    -> Form values output
checkboxField =
    CheckboxField.form Checkbox


{-| Create a form that contains a single select field.

It has a very similar configuration to [`textField`](#textField), the only difference is:

  - Its attributes are [`SelectField.Attributes`](Form-Field-SelectField#Attributes)
    instead of [`TextField.Attributes`](Form-Field-TextField#Attributes).

-}
selectField :
    { parser : String -> Result String output
    , value : values -> Value String
    , update : Value String -> values -> values
    , attributes : SelectField.Attributes
    }
    -> Form values output
selectField =
    SelectField.form Select



-- Composition


{-| Create an **empty** form that always succeeds when submitted, returning the given `output`.

It might seem pointless on its own, but it becomes useful when used in combination with other
functions. The docs for [`append`](#append) have some great examples.

-}
succeed : output -> Form values output
succeed =
    Base.succeed


{-| Append a form to another one while **capturing** the `output` of the first one.

For instance, we could build a signup form:

    signupEmailField : Form { r | email : Value String } EmailAddress
    signupEmailField =
        Form.emailField
            { -- ...
            }

    signupPasswordField : Form { r | password : Value String } Password
    signupPasswordField =
        Form.passwordField
            { -- ...
            }

    signupForm :
        Form
            { email : Value String
            , password : Value String
            }
            ( EmailAddress, Password )
    signupForm =
        Form.succeed (,)
            |> Form.append signupEmailField
            |> Form.append signupPasswordField

In this pipeline, `append` is being used to feed the `(,)` function and combine two forms
into a bigger form that outputs `( EmailAddress, Password )` when submitted.

**Note:** You can use [`succeed`](#succeed) smartly to **skip** some values.
This is useful when you want to append some fields in your form to perform validation, but
you do not care about the `output` they produce. An example of this is a "repeat password" field:

    repeatPasswordField :
        String
        -> Form { r | repeatPassword : Value String } ()
    repeatPasswordField currentPassword =
        Form.passwordField
            { parser =
                \repeatedPassword ->
                    if repeatedPassword == currentPassword then
                        Ok ()
                    else
                        Err "the passwords do not match"
            , value = .repeatPassword
            , update =
                \newValue values ->
                    { values | repeatPassword = newValue }
            , attributes =
                { label = "Repeat password"
                , placeholder = "Type your password again..."
                }
            }

    passwordForm :
        String
        ->
            Form
                { password : Value String
                , repeatPassword : Value String
                }
                Password
    passwordForm currentPassword =
        Form.succeed (\password repeatedPassword -> password)
            |> Form.append passwordField
            |> Form.append (repeatPasswordField currentPassword)

-}
append : Form values a -> Form values (a -> b) -> Form values b
append =
    Base.append


{-| Make a form optional. An optional form succeeds when:

  - All of its fields are **empty**, producing `Nothing`
  - All of its fields are **correct**, producing `Just` the `output`

-}
optional : Form values output -> Form values (Maybe output)
optional =
    Base.optional



-- Output


{-| Represents a form field.

If you are building your own form renderer you will probably need to pattern match this type,
using the result of [`fill`](#fill).

-}
type Field values
    = Text TextField.Type (TextField values)
    | Checkbox (CheckboxField values)
    | Select (SelectField values)


{-| Fill a form with some `values`.

It returns:

  - a list of the fields of the form, alongside their errors
  - the result of the filled form, which can either be:
      - a non-empty list of validation errors
      - the correct `output`

-}
fill :
    Form values output
    -> values
    ->
        { fields : List ( Field values, Maybe Error )
        , result : Result ( Error, List Error ) output
        }
fill =
    Base.fill
