module Form
    exposing
        ( Field(..)
        , Form
        , TextType(..)
        , andThen
        , append
        , checkboxField
        , emailField
        , fill
        , group
        , map
        , mapValues
        , meta
        , numberField
        , optional
        , passwordField
        , radioField
        , rangeField
        , selectField
        , succeed
        , textField
        , textareaField
        )

{-| Build [composable forms](#Form) comprised of [fields](#fields).


# Definition

@docs Form


# Fields

@docs textField, emailField, passwordField, textareaField, numberField, rangeField, checkboxField
@docs radioField, selectField


# Composition

All the functions in [the previous section](#fields) produce a `Form` with a **single**
field. You might then be wondering: "How do I create a `Form` with multiple fields?!"
Well, as the name of this package says: `Form` is composable! This section explains how you
can combine different forms into bigger and more complex ones.

@docs succeed, append, optional, group, andThen, meta


# Mapping

@docs map, mapValues


# Output

This section describes how to fill a `Form` with its `values` and obtain its
different fields and its `output`. This is mostly used to write custom view code.

If you just want to render a simple form as `Html`, check [`Form.View`](Form-View) first as it
might suit your needs.

@docs Field, TextType, fill

-}

import Form.Base as Base
import Form.Base.CheckboxField as CheckboxField exposing (CheckboxField)
import Form.Base.NumberField as NumberField exposing (NumberField)
import Form.Base.RadioField as RadioField exposing (RadioField)
import Form.Base.RangeField as RangeField exposing (RangeField)
import Form.Base.SelectField as SelectField exposing (SelectField)
import Form.Base.TextField as TextField exposing (TextField)
import Form.Error exposing (Error)
import Form.Value exposing (Value)


-- Definition


{-| A `Form` collects and validates user input using fields. When a form is filled with `values`,
it produces some `output` if validation succeeds.

For example, a `Form String EmailAddress` is a form that is filled with a `String` and produces
an `EmailAddress` when valid. This form could very well be an [`emailField`](#emailField)!

-}
type alias Form values output =
    Base.Form values output (Field values)



-- Fields


{-| Create a form that contains a single text field.

It requires some configuration:

  - `parser` specifies how to validate the field. It needs a function that processes the value of
    the field and produces a `Result` of either:
      - a `String` describing an error
      - a correct `output`
  - `value` describes how to obtain the field [`Value`](Form-Value) from the form `values`
  - `update` describes how the current form `values` should be updated with a new field
    [`Value`](Form-Value)
  - `attributes` let you define the specific attributes of the field (`label` and `placeholder`
    in this case, see [`TextField.Attributes`](Form-Base-TextField#Attributes))

It might seem like a lot of configuration, but don't be scared! In practice, it isn't!
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
    TextField.form (Text TextRaw)


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
    TextField.form (Text TextEmail)


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
    TextField.form (Text TextPassword)


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
    TextField.form (Text TextArea)


{-| Create a form that contains a single search field.

It has the same configuration options as [`textField`](#textField).

-}
searchField :
    { parser : String -> Result String output
    , value : values -> Value String
    , update : Value String -> values -> values
    , attributes : TextField.Attributes
    }
    -> Form values output
searchField =
    TextField.form (Text TextSearch)


{-| Create a form that contains a single number field.

It has a very similar configuration to [`textField`](#textField), the only difference is:

  - Its attributes are [`NumberField.Attributes`](Form-Base-NumberField#Attributes)
    instead of [`TextField.Attributes`](Form-Base-TextField#Attributes).

-}
numberField :
    { parser : Float -> Result String output
    , value : values -> Value Float
    , update : Value Float -> values -> values
    , attributes : NumberField.Attributes Float
    }
    -> Form values output
numberField =
    NumberField.form Number


{-| Create a form that contains a single range field.

It has a very similar configuration to [`textField`](#textField), the only difference is:

  - Its attributes are [`RangeField.Attributes`](Form-Base-RangeField#Attributes)
    instead of [`TextField.Attributes`](Form-Base-TextField#Attributes).

-}
rangeField :
    { parser : Float -> Result String output
    , value : values -> Value Float
    , update : Value Float -> values -> values
    , attributes : RangeField.Attributes Float
    }
    -> Form values output
rangeField =
    RangeField.form Range


{-| Create a form that contains a single checkbox field.

It has a very similar configuration to [`textField`](#textField), the only differences are:

  - Its value is a `Bool` instead of `String`.
  - Its attributes are [`CheckboxField.Attributes`](Form-Base-CheckboxField#Attributes)
    instead of [`TextField.Attributes`](Form-Base-TextField#Attributes).

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


{-| Create a form that contains a single fieldset of radio fields.

It has a very similar configuration to [`textField`](#textField), the only difference is:

  - Its attributes are [`RadioField.Attributes`](Form-Base-RadioField#Attributes)
    instead of [`TextField.Attributes`](Form-Base-TextField#Attributes).

-}
radioField :
    { parser : String -> Result String output
    , value : values -> Value String
    , update : Value String -> values -> values
    , attributes : RadioField.Attributes
    }
    -> Form values output
radioField =
    RadioField.form Radio


{-| Create a form that contains a single select field.

It has a very similar configuration to [`textField`](#textField), the only difference is:

  - Its attributes are [`SelectField.Attributes`](Form-Base-SelectField#Attributes)
    instead of [`TextField.Attributes`](Form-Base-TextField#Attributes).

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


{-| Create an **empty** form that always succeeds when filled, returning the given `output`.

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

    passwordForm :
        Form
            { password : Value String
            , repeatPassword : Value String
            }
            Password
    passwordForm =
        Form.succeed (\password repeatedPassword -> password)
            |> Form.append passwordField
            |> Form.append repeatPasswordField

-}
append : Form values a -> Form values (a -> b) -> Form values b
append =
    Base.append


{-| Make a form optional. An optional form succeeds when:

  - All of its fields are **empty**, producing `Nothing`
  - All of its fields are **correct**, producing `Just` the `output`

Let's say we want to optionally ask for a website name and address:

    websiteForm =
        Form.optional
            (Form.succeed Website
                |> Form.append websiteNameField
                |> Form.append websiteAddressField
            )

This `websiteForm` will only be valid if **both** fields are blank, or **both** fields
are filled correctly.

-}
optional : Form values output -> Form values (Maybe output)
optional =
    Base.optional


{-| Wraps a form in a group.

Using this function does not affect the behavior of the form in any way. However, groups of fields
might be rendered differently. For instance, [`Form.View`](Form-View) renders groups of
fields horizontally.

-}
group : Form values output -> Form values output
group form =
    Base.custom
        (\values ->
            let
                { fields, result, isEmpty } =
                    Base.fill form values
            in
            { field = Group fields
            , result = result
            , isEmpty = isEmpty
            }
        )


{-| Fill a form `andThen` fill another one.

This is useful to build dynamic forms. For instance, you could use the output of a `selectField`
to choose between different forms, like this:

    type Msg
        = CreatePost Post.Body
        | CreateQuestion Question.Title Question.Body

    type ContentType
        = Post
        | Question

    type alias Values =
        { type_ : Value String
        , title : Value String
        , body : Value String
        }

    contentForm : Form Values Msg
    contentForm =
        Form.selectField
            { parser =
                \value ->
                    case value of
                        "post" ->
                            Ok Post

                        "question" ->
                            Ok Question

                        _ ->
                            Err "invalid content type"
            , value = .type_
            , update = \newValue values -> { values | type_ = newValue }
            , attributes =
                { label = "Which type of content do you want to create?"
                , placeholder = "Choose a type of content"
                , options = [ ( "post", "Post" ), ( "question", "Question" ) ]
                }
            }
            |> Form.andThen
                (\contentType ->
                    case contentType of
                        Post ->
                            let
                                bodyField =
                                    Form.textareaField
                                        { -- ...
                                        }
                            in
                            Form.succeed CreatePost
                                |> Form.append bodyField

                        Question ->
                            let
                                titleField =
                                    Form.textField
                                        { -- ...
                                        }

                                bodyField =
                                    Form.textareaField
                                        { -- ...
                                        }
                            in
                            Form.succeed CreateQuestion
                                |> Form.append titleField
                                |> Form.append bodyField
                )

-}
andThen : (a -> Form values b) -> Form values a -> Form values b
andThen =
    Base.andThen


{-| Build a form that depends on its own `values`.

This is useful when you need some fields to perform validation based on
the values of other fields. An example of this is a "repeat password" field:

    repeatPasswordField :
        Form
            { r
                | password : Value String
                , repeatPassword : Value String
            }
            ()
    repeatPasswordField =
        Form.meta
            (\values ->
                Form.passwordField
                    { parser =
                        \value ->
                            if Just value == Value.raw values.password then
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
            )

-}
meta : (values -> Form values output) -> Form values output
meta =
    Base.meta



-- Mapping


{-| Transform the `output` of a form.

This function can help you to keep forms decoupled from specific view messages:

    Form.map SignUp signupForm

-}
map : (a -> b) -> Form values a -> Form values b
map =
    Base.map


{-| Transform the `values` of a form.

This can be useful when you need to nest forms:

    type alias SignupValues =
        { email : Value String
        , password : Value String
        , address : AddressValues
        }

    addressForm : Form AddressValues Address

    signupForm : Form SignupValues Msg
    signupForm =
        Form.succeed SignUp
            |> Form.append emailField
            |> Form.append passwordField
            |> Form.append
                (Form.mapValues
                    { value = .address
                    , update = \newAddress values -> { values | address = newAddress }
                    }
                    addressForm
                )

-}
mapValues : { value : a -> b, update : b -> a -> a } -> Form b output -> Form a output
mapValues { value, update } form =
    Base.meta
        (\values ->
            let
                mapField field =
                    case field of
                        Text textType field ->
                            Text textType { field | update = mapUpdate field.update }

                        Number field ->
                            Number { field | update = mapUpdate field.update }

                        Range field ->
                            Range { field | update = mapUpdate field.update }

                        Checkbox field ->
                            Checkbox { field | update = mapUpdate field.update }

                        Radio field ->
                            Radio { field | update = mapUpdate field.update }

                        Select field ->
                            Select { field | update = mapUpdate field.update }

                        Group fields ->
                            Group (List.map (\( field, error ) -> ( mapField field, error )) fields)

                mapUpdate fn value =
                    update (fn value) values
            in
            form
                |> Base.mapValues value
                |> Base.mapField mapField
        )



-- Output


{-| Represents a form field.

If you are writing custom view code you will probably need to pattern match this type,
using the result of [`fill`](#fill).

-}
type Field values
    = Text TextType (TextField values)
    | Number (NumberField Float values)
    | Range (RangeField Float values)
    | Checkbox (CheckboxField values)
    | Radio (RadioField values)
    | Select (SelectField values)
    | Group (List ( Field values, Maybe Error ))


{-| Represents a type of text field
-}
type TextType
    = TextRaw
    | TextEmail
    | TextPassword
    | TextArea
    | TextSearch


{-| Fill a form with some `values`.

It returns:

  - a list of the fields of the form, alongside their errors
  - the result of the filled form, which can either be:
      - a non-empty list of validation errors
      - the correct `output`
  - whether the form is empty or not

-}
fill :
    Form values output
    -> values
    ->
        { fields : List ( Field values, Maybe Error )
        , result : Result ( Error, List Error ) output
        , isEmpty : Bool
        }
fill =
    Base.fill
