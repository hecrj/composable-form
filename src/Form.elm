module Form
    exposing
        ( Field(..)
        , Form
        , append
        , checkboxField
        , emailField
        , fields
        , optional
        , passwordField
        , result
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


# Results

This section describes how to obtain the different [`fields`](#fields) that comprise a `Form` and
how to obtain the [resulting](#result) `output`. This is mostly used to build custom form renderers.

If you just want to render a simple `Form` as `Html`, check [`Form.View`](Form-View) first as it
might suit your needs just well.

@docs Field, fields, result

-}

import Form.Base as Base
import Form.Error exposing (Error)
import Form.Field.CheckboxField as CheckboxField exposing (CheckboxField)
import Form.Field.SelectField as SelectField exposing (SelectField)
import Form.Field.TextField as TextField exposing (TextField)
import Form.Value exposing (Value)


-- Definition


{-| A `Form` represents one or more fields. Form fields are filled with some `values` and together
produce an `output` when submitted.

For example, a `Form String EmailAddress` is a form that is filled with a `String` and produces
an `EmailAddress` when submitted. This form could very well be an [`emailField`](#emailField)!

-}
type alias Form values output =
    Base.Form values output (Field values)



-- Fields


{-| Produces a `Form` that contains a single text field.

It requires some configuration:

  - `parser` specifies how to validate the field. It needs a function that processes the value of
    the field and produces either:
      - a correct `output`
      - a `String` describing an error
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
    TextField.form (Text Raw)


{-| Produces a `Form` that contains a single email field.

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
    TextField.form (Text Email)


{-| Produces a `Form` that contains a single password field.

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
    TextField.form (Text Password)


{-| Produces a `Form` that contains a single textarea field.

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
    TextField.form (Text Textarea)


{-| Produces a `Form` that contains a single checkbox field.

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
    CheckboxField.build Checkbox


{-| Produces a `Form` that contains a single select field.

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
    SelectField.build Select



-- Composition


{-| Produces an **empty** form that always succeeds when submitted, returning the given `output`.

It might seem pointless on its own, but it becomes useful when used in combination with other
functions. The docs for [`append`](#append) have some great examples.

-}
succeed : output -> Form values output
succeed =
    Base.succeed


{-| Appends a form to another one while **capturing** the `output` of the first one.

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


{-| Makes a `Form` optional. An optional form succeeds when:

  - Its `values` are **empty**, producing `Nothing`
  - Its `values` are **correct**, producing `Just` the `output`

-}
optional : Form values output -> Form values (Maybe output)
optional =
    Base.optional



-- Results


{-| Represents a form field
-}
type Field values
    = Text TextType (TextField values)
    | Checkbox (CheckboxField values)
    | Select (SelectField values)


{-| Represents a type of text field
-}
type TextType
    = Raw
    | Email
    | Password
    | Textarea


{-| Given a `Form` and its `values`, it obtains the fields of the form alongside their first error.
-}
fields : Form values output -> values -> List ( Field values, Maybe Error )
fields =
    Base.fields


{-| Given a `Form` and its `values`, it produces a result with either:

  - A non-empty list of validation errors
  - The correct `output` of the form

-}
result : Form values output -> values -> Result ( Error, List Error ) output
result =
    Base.result
