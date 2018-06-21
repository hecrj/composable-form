module Base exposing (..)

import Expect exposing (Expectation)
import Form exposing (Form)
import Form.Base
import Form.Error as Error
import Form.Value as Value exposing (Value)
import Test exposing (..)


-- Custom fields


field : Test
field =
    let
        customField =
            Form.Base.field { isEmpty = String.isEmpty } identity

        form =
            customField
                { parser =
                    \string ->
                        if string == invalidString then
                            Err "invalid input"
                        else
                            Ok string
                , value = identity
                , update = \value _ -> value
                , attributes = attributes
                }

        invalidString =
            "invalid"

        attributes =
            { a = 1, b = "some attribute" }

        fill =
            Form.Base.fill form

        withFieldAndError fn result =
            case result.fields of
                [ fieldAndError_ ] ->
                    fn fieldAndError_

                _ ->
                    Expect.fail "fields do not contain a single field"

        withField fn =
            withFieldAndError (Tuple.first >> fn)

        withFieldError fn =
            withFieldAndError (Tuple.second >> fn)
    in
    describe "Form.Base.field"
        [ describe "when filled"
            [ test "contains a single field" <|
                \_ ->
                    fill Value.blank
                        |> .fields
                        |> List.length
                        |> Expect.equal 1
            , test "builds the field with its current value" <|
                \_ ->
                    let
                        value =
                            Value.filled "hello"
                    in
                    fill value
                        |> withField (.value >> Expect.equal value)
            , test "builds the field with an update helper" <|
                \_ ->
                    let
                        value =
                            Value.filled "hello"

                        newValue =
                            "hello world"
                    in
                    fill value
                        |> withField
                            (\field_ ->
                                field_.update newValue
                                    |> Expect.equal (Value.update newValue value)
                            )
            , test "builds the field with its attributes" <|
                \_ ->
                    fill Value.blank
                        |> withField (.attributes >> Expect.equal attributes)
            ]
        , describe "when filled with a valid value"
            [ test "there is not field error" <|
                \_ ->
                    fill (Value.filled "hello")
                        |> withFieldError (Expect.equal Nothing)
            , test "result is the correct output" <|
                \_ ->
                    fill (Value.filled "hello")
                        |> .result
                        |> Expect.equal (Ok "hello")
            ]
        , describe "when filled with a blank value"
            [ test "field error is RequiredFieldIsEmpty" <|
                \_ ->
                    fill Value.blank
                        |> withFieldError (Expect.equal (Just Error.RequiredFieldIsEmpty))
            , test "result is a RequiredFieldIsEmpty error" <|
                \_ ->
                    fill Value.blank
                        |> .result
                        |> Expect.equal (Err ( Error.RequiredFieldIsEmpty, [] ))
            , test "form is empty" <|
                \_ ->
                    fill Value.blank
                        |> .isEmpty
                        |> Expect.equal True
            ]
        , describe "when filled with an empty value"
            [ test "field error is RequiredFieldIsEmpty" <|
                \_ ->
                    fill (Value.filled "")
                        |> withFieldError (Expect.equal (Just Error.RequiredFieldIsEmpty))
            , test "result is a RequiredFieldIsEmpty error" <|
                \_ ->
                    fill (Value.filled "")
                        |> .result
                        |> Expect.equal (Err ( Error.RequiredFieldIsEmpty, [] ))
            , test "form is empty" <|
                \_ ->
                    fill (Value.filled "")
                        |> .isEmpty
                        |> Expect.equal True
            ]
        , describe "when filled with an invalid value" <|
            [ test "field error is ValidationFailed" <|
                \_ ->
                    fill (Value.filled invalidString)
                        |> withFieldError (Expect.equal (Just (Error.ValidationFailed "invalid input")))
            , test "result is a ValidationFailed error" <|
                \_ ->
                    fill (Value.filled invalidString)
                        |> .result
                        |> Expect.equal (Err ( Error.ValidationFailed "invalid input", [] ))
            , test "form is not empty" <|
                \_ ->
                    fill (Value.filled "hello")
                        |> .isEmpty
                        |> Expect.equal False
            ]
        ]


type CustomField
    = CustomField


custom : Test
custom =
    let
        invalidValue =
            "invalid"

        form =
            Form.Base.custom
                (\value ->
                    { field = CustomField
                    , result =
                        if value == invalidValue then
                            Err
                                ( Error.ValidationFailed "error 1"
                                , [ Error.ValidationFailed "error2"
                                  , Error.ValidationFailed "error 3"
                                  ]
                                )
                        else
                            Ok "valid"
                    , isEmpty = False
                    }
                )

        fill =
            Form.Base.fill form
    in
    describe "custom"
        [ test "it returns the correct result when the value is valid" <|
            \_ ->
                fill "hello"
                    |> Expect.equal
                        { fields = [ ( CustomField, Nothing ) ]
                        , result = Ok "valid"
                        , isEmpty = False
                        }
        , test "it returns the errors when the value is invalid" <|
            \_ ->
                fill invalidValue
                    |> Expect.equal
                        { fields =
                            [ ( CustomField
                              , Just (Error.ValidationFailed "error 1")
                              )
                            ]
                        , result =
                            Err
                                ( Error.ValidationFailed "error 1"
                                , [ Error.ValidationFailed "error2"
                                  , Error.ValidationFailed "error 3"
                                  ]
                                )
                        , isEmpty = False
                        }
        ]



-- Composition


succeed : Test
succeed =
    describe "succeed"
        [ test "returns an empty form that always succeeds" <|
            \_ ->
                let
                    form =
                        Form.Base.succeed ()
                in
                Form.Base.fill form ()
                    |> Expect.equal
                        { fields = []
                        , result = Ok ()
                        , isEmpty = True
                        }
        ]


append : Test
append =
    let
        form =
            Form.Base.succeed (,)
                |> Form.Base.append emailField
                |> Form.Base.append passwordField

        fill =
            Form.Base.fill form

        validValues =
            { email = Value.filled "hello@world.com"
            , password = Value.filled "12345678"
            }

        invalidValues =
            { email = Value.filled "hello"
            , password = Value.filled "123"
            }

        emptyValues =
            { email = Value.blank
            , password = Value.blank
            }
    in
    describe "append"
        [ describe "when filled"
            [ test "contains the appended field" <|
                \_ ->
                    fill { email = Value.blank, password = Value.blank }
                        |> .fields
                        |> List.length
                        |> Expect.equal 2
            ]
        , describe "when filled with valid values"
            [ test "contains no field errors" <|
                \_ ->
                    fill validValues
                        |> .fields
                        |> List.map Tuple.second
                        |> Expect.equal [ Nothing, Nothing ]
            , test "results in the correct output" <|
                \_ ->
                    fill validValues
                        |> .result
                        |> Expect.equal (Ok ( "hello@world.com", "12345678" ))
            ]
        , describe "when filled with invalid values"
            [ test "contains the first error of each field" <|
                \_ ->
                    fill invalidValues
                        |> .fields
                        |> List.map Tuple.second
                        |> Expect.equal
                            [ Just (Error.ValidationFailed emailError)
                            , Just (Error.ValidationFailed passwordError)
                            ]
            , test "results in a non-empty list with the errors of the fields" <|
                \_ ->
                    fill invalidValues
                        |> .result
                        |> Expect.equal
                            (Err
                                ( Error.ValidationFailed emailError
                                , [ Error.ValidationFailed passwordError ]
                                )
                            )
            , test "is not empty" <|
                \_ ->
                    fill invalidValues
                        |> .isEmpty
                        |> Expect.equal False
            ]
        , describe "when filled with empty values"
            [ test "is empty" <|
                \_ ->
                    fill emptyValues
                        |> .isEmpty
                        |> Expect.equal True
            ]
        ]


type ContentAction
    = CreatePost String
    | CreateQuestion String String


andThen : Test
andThen =
    let
        titleField =
            Form.textField
                { parser = Ok
                , value = .title
                , update = \value values -> { values | title = value }
                , attributes =
                    { label = "Title"
                    , placeholder = "Write a title..."
                    }
                }

        bodyField =
            Form.textareaField
                { parser = Ok
                , value = .body
                , update = \value values -> { values | body = value }
                , attributes =
                    { label = "Body"
                    , placeholder = "Write the body..."
                    }
                }

        form =
            contentTypeField
                |> Form.Base.andThen
                    (\contentType ->
                        case contentType of
                            Post ->
                                Form.Base.succeed CreatePost
                                    |> Form.Base.append bodyField

                            Question ->
                                Form.Base.succeed CreateQuestion
                                    |> Form.Base.append titleField
                                    |> Form.Base.append bodyField
                    )

        fill =
            Form.Base.fill form
    in
    describe "andThen"
        [ describe "when the parent fields are valid"
            [ test "contains the parent and the child fields" <|
                \_ ->
                    fill { contentType = Value.filled "question", title = Value.blank, body = Value.blank }
                        |> .fields
                        |> List.length
                        |> Expect.equal 3
            , describe "when the child fields are valid" <|
                [ test "results in the correct output" <|
                    \_ ->
                        fill
                            { contentType = Value.filled "question"
                            , title = Value.filled "Some title"
                            , body = Value.filled "Some body"
                            }
                            |> .result
                            |> Expect.equal (Ok (CreateQuestion "Some title" "Some body"))
                ]
            , describe "when the child fields are invalid" <|
                [ test "results in the errors of the child fields" <|
                    \_ ->
                        fill
                            { contentType = Value.filled "question"
                            , title = Value.filled ""
                            , body = Value.blank
                            }
                            |> .result
                            |> Expect.equal (Err ( Error.RequiredFieldIsEmpty, [ Error.RequiredFieldIsEmpty ] ))
                ]
            , test "is not empty" <|
                \_ ->
                    fill { contentType = Value.filled "question", title = Value.blank, body = Value.blank }
                        |> .isEmpty
                        |> Expect.equal False
            ]
        , describe "when the parent fields are empty" <|
            [ test "is empty" <|
                \_ ->
                    fill { contentType = Value.blank, title = Value.blank, body = Value.blank }
                        |> .isEmpty
                        |> Expect.equal True
            ]
        , describe "when some parent field is invalid"
            [ test "contains only the parent fields" <|
                \_ ->
                    fill { contentType = Value.filled "invalid", title = Value.blank, body = Value.blank }
                        |> .fields
                        |> List.length
                        |> Expect.equal 1
            , test "results in only the parent errors" <|
                \_ ->
                    fill { contentType = Value.filled "invalid", title = Value.blank, body = Value.blank }
                        |> .result
                        |> Expect.equal (Err ( Error.ValidationFailed contentTypeError, [] ))
            , test "is not empty" <|
                \_ ->
                    fill { contentType = Value.filled "invalid", title = Value.blank, body = Value.blank }
                        |> .isEmpty
                        |> Expect.equal False
            ]
        ]


meta : Test
meta =
    let
        fill =
            Form.Base.fill repeatPasswordField
    in
    describe "meta"
        [ describe "when filled"
            [ test "contains the correct fields" <|
                \_ ->
                    fill { password = Value.blank, repeatPassword = Value.blank }
                        |> .fields
                        |> List.length
                        |> Expect.equal 1
            , test "provides access to the values of the form" <|
                \_ ->
                    let
                        correct =
                            fill { password = Value.filled "123", repeatPassword = Value.filled "123" }

                        incorrect =
                            fill { password = Value.filled "123", repeatPassword = Value.filled "456" }
                    in
                    ( correct.result, incorrect.result )
                        |> Expect.equal ( Ok (), Err ( Error.ValidationFailed repeatPasswordError, [] ) )
            ]
        ]



-- Email field


emailField : Form { r | email : Value String } String
emailField =
    Form.emailField
        { parser =
            \value ->
                if String.contains "@" value then
                    Ok value
                else
                    Err emailError
        , value = .email
        , update = \value values -> { values | email = value }
        , attributes =
            { label = "E-Mail"
            , placeholder = "Type your e-mail..."
            }
        }


emailError : String
emailError =
    "The e-mail should contain a '@'"



-- Password field


passwordField : Form { r | password : Value String } String
passwordField =
    Form.passwordField
        { parser =
            \value ->
                if String.length value >= 8 then
                    Ok value
                else
                    Err passwordError
        , value = .password
        , update = \value values -> { values | password = value }
        , attributes =
            { label = "Password"
            , placeholder = "Type your password..."
            }
        }


passwordError : String
passwordError =
    "The password should have at least 8 characters"



-- Repeat password field


repeatPasswordField : Form { r | password : Value String, repeatPassword : Value String } ()
repeatPasswordField =
    Form.Base.meta
        (\values ->
            Form.passwordField
                { parser =
                    \value ->
                        if Just value == Value.raw values.password then
                            Ok ()
                        else
                            Err repeatPasswordError
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


repeatPasswordError : String
repeatPasswordError =
    "the passwords do not match"



-- Content type field


type ContentType
    = Post
    | Question


contentTypeField : Form { r | contentType : Value String } ContentType
contentTypeField =
    Form.selectField
        { parser =
            \value ->
                case value of
                    "post" ->
                        Ok Post

                    "question" ->
                        Ok Question

                    _ ->
                        Err contentTypeError
        , value = .contentType
        , update = \value values -> { values | contentType = value }
        , attributes =
            { label = "Content type"
            , placeholder = "Select a type of content"
            , options = [ ( "post", "Post" ), ( "question", "Question" ) ]
            }
        }


contentTypeError : String
contentTypeError =
    "Invalid content type"
