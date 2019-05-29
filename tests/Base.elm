module Base exposing
    ( ContentAction(..)
    , ContentType(..)
    , CustomField(..)
    , andThen
    , append
    , contentTypeError
    , contentTypeField
    , custom
    , emailError
    , emailField
    , field
    , map
    , meta
    , optional
    , passwordError
    , passwordField
    , repeatPasswordError
    , repeatPasswordField
    , succeed
    )

import Expect exposing (Expectation)
import Form exposing (Form)
import Form.Base
import Form.Error as Error
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
                , error =
                    \string ->
                        if string == externalErrorString then
                            Just "external error"

                        else
                            Nothing
                , attributes = attributes
                }

        invalidString =
            "invalid"

        externalErrorString =
            "external_error"

        attributes =
            { a = 1, b = "some attribute" }

        fill =
            Form.Base.fill form

        withFieldAndError fn result =
            case result.fields of
                [ field_ ] ->
                    fn field_

                _ ->
                    Expect.fail "fields do not contain a single field"

        withField fn =
            withFieldAndError (.state >> fn)

        withFieldError fn =
            withFieldAndError (.error >> fn)
    in
    describe "Form.Base.field"
        [ describe "when filled"
            [ test "contains a single field" <|
                \_ ->
                    fill ""
                        |> .fields
                        |> List.length
                        |> Expect.equal 1
            , test "builds the field with its current value" <|
                \_ ->
                    let
                        value =
                            "hello"
                    in
                    fill value
                        |> withField (.value >> Expect.equal value)
            , test "builds the field with an update helper" <|
                \_ ->
                    fill "hello"
                        |> withField
                            (\field_ ->
                                field_.update "hello world"
                                    |> Expect.equal "hello world"
                            )
            , test "builds the field with its attributes" <|
                \_ ->
                    fill ""
                        |> withField (.attributes >> Expect.equal attributes)
            ]
        , describe "when filled with a valid value"
            [ test "there is not field error" <|
                \_ ->
                    fill "hello"
                        |> withFieldError (Expect.equal Nothing)
            , test "result is the correct output" <|
                \_ ->
                    fill "hello"
                        |> .result
                        |> Expect.equal (Ok "hello")
            ]
        , describe "when filled with a blank value"
            [ test "field error is RequiredFieldIsEmpty" <|
                \_ ->
                    fill ""
                        |> withFieldError (Expect.equal (Just Error.RequiredFieldIsEmpty))
            , test "result is a RequiredFieldIsEmpty error" <|
                \_ ->
                    fill ""
                        |> .result
                        |> Expect.equal (Err ( Error.RequiredFieldIsEmpty, [] ))
            , test "form is empty" <|
                \_ ->
                    fill ""
                        |> .isEmpty
                        |> Expect.equal True
            ]
        , describe "when filled with an empty value"
            [ test "field error is RequiredFieldIsEmpty" <|
                \_ ->
                    fill ""
                        |> withFieldError (Expect.equal (Just Error.RequiredFieldIsEmpty))
            , test "result is a RequiredFieldIsEmpty error" <|
                \_ ->
                    fill ""
                        |> .result
                        |> Expect.equal (Err ( Error.RequiredFieldIsEmpty, [] ))
            , test "form is empty" <|
                \_ ->
                    fill ""
                        |> .isEmpty
                        |> Expect.equal True
            ]
        , describe "when filled with an invalid value" <|
            [ test "field error is ValidationFailed" <|
                \_ ->
                    fill invalidString
                        |> withFieldError (Expect.equal (Just (Error.ValidationFailed "invalid input")))
            , test "result is a ValidationFailed error" <|
                \_ ->
                    fill invalidString
                        |> .result
                        |> Expect.equal (Err ( Error.ValidationFailed "invalid input", [] ))
            , test "form is not empty" <|
                \_ ->
                    fill invalidString
                        |> .isEmpty
                        |> Expect.equal False
            ]
        , describe "when there is an external error" <|
            [ test "field error is External" <|
                \_ ->
                    fill externalErrorString
                        |> withFieldError (Expect.equal (Just (Error.External "external error")))
            , test "result is an External error" <|
                \_ ->
                    fill externalErrorString
                        |> .result
                        |> Expect.equal (Err ( Error.External "external error", [] ))
            , test "form is not empty" <|
                \_ ->
                    fill externalErrorString
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
                    { state = CustomField
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
                        { fields =
                            [ { state = CustomField
                              , error = Nothing
                              , isDisabled = False
                              }
                            ]
                        , result = Ok "valid"
                        , isEmpty = False
                        }
        , test "it returns the errors when the value is invalid" <|
            \_ ->
                fill invalidValue
                    |> Expect.equal
                        { fields =
                            [ { state = CustomField
                              , error = Just (Error.ValidationFailed "error 1")
                              , isDisabled = False
                              }
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


map : Test
map =
    let
        form =
            Form.Base.map String.length passwordField
    in
    describe "map"
        [ test "applies the given function to the form output" <|
            \_ ->
                { password = "12345678" }
                    |> Form.Base.fill form
                    |> .result
                    |> Expect.equal (Ok 8)
        ]


append : Test
append =
    let
        form =
            Form.Base.succeed Tuple.pair
                |> Form.Base.append emailField
                |> Form.Base.append passwordField

        fill =
            Form.Base.fill form

        validValues =
            { email = "hello@world.com"
            , password = "12345678"
            }

        invalidValues =
            { email = "hello"
            , password = "123"
            }

        emptyValues =
            { email = ""
            , password = ""
            }
    in
    describe "append"
        [ describe "when filled"
            [ test "contains the appended field" <|
                \_ ->
                    fill { email = "", password = "" }
                        |> .fields
                        |> List.length
                        |> Expect.equal 2
            ]
        , describe "when filled with valid values"
            [ test "contains no field errors" <|
                \_ ->
                    fill validValues
                        |> .fields
                        |> List.map .error
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
                        |> List.map .error
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
                , error = always Nothing
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
                , error = always Nothing
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
                    fill { contentType = "question", title = "", body = "" }
                        |> .fields
                        |> List.length
                        |> Expect.equal 3
            , describe "when the child fields are valid" <|
                [ test "results in the correct output" <|
                    \_ ->
                        fill
                            { contentType = "question"
                            , title = "Some title"
                            , body = "Some body"
                            }
                            |> .result
                            |> Expect.equal (Ok (CreateQuestion "Some title" "Some body"))
                ]
            , describe "when the child fields are invalid" <|
                [ test "results in the errors of the child fields" <|
                    \_ ->
                        fill
                            { contentType = "question"
                            , title = ""
                            , body = ""
                            }
                            |> .result
                            |> Expect.equal (Err ( Error.RequiredFieldIsEmpty, [ Error.RequiredFieldIsEmpty ] ))
                ]
            , test "is not empty" <|
                \_ ->
                    fill { contentType = "question", title = "", body = "" }
                        |> .isEmpty
                        |> Expect.equal False
            ]
        , describe "when the parent fields are empty" <|
            [ test "is empty" <|
                \_ ->
                    fill { contentType = "", title = "", body = "" }
                        |> .isEmpty
                        |> Expect.equal True
            ]
        , describe "when some parent field is invalid"
            [ test "contains only the parent fields" <|
                \_ ->
                    fill { contentType = "invalid", title = "", body = "" }
                        |> .fields
                        |> List.length
                        |> Expect.equal 1
            , test "results in only the parent errors" <|
                \_ ->
                    fill { contentType = "invalid", title = "", body = "" }
                        |> .result
                        |> Expect.equal (Err ( Error.ValidationFailed contentTypeError, [] ))
            , test "is not empty" <|
                \_ ->
                    fill { contentType = "invalid", title = "", body = "" }
                        |> .isEmpty
                        |> Expect.equal False
            ]
        ]


optional : Test
optional =
    let
        form =
            Form.Base.succeed Tuple.pair
                |> Form.Base.append emailField
                |> Form.Base.append passwordField
                |> Form.optional

        fill =
            Form.Base.fill form

        emptyValues =
            { email = "", password = "" }

        validValues =
            { email = "hello@world.com", password = "12345678" }

        invalidValues =
            { email = "hello", password = "123" }
    in
    describe "optional"
        [ describe "when filled with empty values"
            [ test "contains no field errors" <|
                \_ ->
                    fill emptyValues
                        |> .fields
                        |> List.map .error
                        |> Expect.equal [ Nothing, Nothing ]
            , test "produces Nothing" <|
                \_ ->
                    fill emptyValues
                        |> .result
                        |> Expect.equal (Ok Nothing)
            ]
        , describe "when filled with valid values"
            [ test "contains no field errors" <|
                \_ ->
                    fill validValues
                        |> .fields
                        |> List.map .error
                        |> Expect.equal [ Nothing, Nothing ]
            , test "results in the correct output" <|
                \_ ->
                    fill validValues
                        |> .result
                        |> Expect.equal (Ok (Just ( "hello@world.com", "12345678" )))
            ]
        , describe "when partially filled"
            [ test "results in required field errors" <|
                \_ ->
                    fill { email = "hello@world.com", password = "" }
                        |> .result
                        |> Expect.equal (Err ( Error.RequiredFieldIsEmpty, [] ))
            ]
        , describe "when filled with invalid values"
            [ test "contains the first error of each field" <|
                \_ ->
                    fill invalidValues
                        |> .fields
                        |> List.map .error
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
                    fill { password = "", repeatPassword = "" }
                        |> .fields
                        |> List.length
                        |> Expect.equal 1
            , test "provides access to the values of the form" <|
                \_ ->
                    let
                        correct =
                            fill { password = "123", repeatPassword = "123" }

                        incorrect =
                            fill { password = "123", repeatPassword = "456" }
                    in
                    ( correct.result, incorrect.result )
                        |> Expect.equal ( Ok (), Err ( Error.ValidationFailed repeatPasswordError, [] ) )
            ]
        ]



-- Email field


emailField : Form { r | email : String } String
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
        , error = always Nothing
        , attributes =
            { label = "E-Mail"
            , placeholder = "Type your e-mail..."
            }
        }


emailError : String
emailError =
    "The e-mail should contain a '@'"



-- Password field


passwordField : Form { r | password : String } String
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
        , error = always Nothing
        , attributes =
            { label = "Password"
            , placeholder = "Type your password..."
            }
        }


passwordError : String
passwordError =
    "The password should have at least 8 characters"



-- Repeat password field


repeatPasswordField : Form { r | password : String, repeatPassword : String } ()
repeatPasswordField =
    Form.Base.meta
        (\values ->
            Form.passwordField
                { parser =
                    \value ->
                        if value == values.password then
                            Ok ()

                        else
                            Err repeatPasswordError
                , value = .repeatPassword
                , update =
                    \newValue values_ ->
                        { values_ | repeatPassword = newValue }
                , error = always Nothing
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


contentTypeField : Form { r | contentType : String } ContentType
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
        , error = always Nothing
        , attributes =
            { label = "Content type"
            , placeholder = "Select a type of content"
            , options = [ ( "post", "Post" ), ( "question", "Question" ) ]
            }
        }


contentTypeError : String
contentTypeError =
    "Invalid content type"
