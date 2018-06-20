module Base exposing (..)

import Expect exposing (Expectation)
import Form
import Form.Base
import Form.Error as Error
import Form.Value as Value
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
        [ describe "fields"
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
            , describe "field error"
                [ test "is RequiredFieldIsEmpty when value is blank" <|
                    \_ ->
                        fill Value.blank
                            |> withFieldError (Expect.equal (Just Error.RequiredFieldIsEmpty))
                , test "is RequiredFieldIsEmpty when value is filled but empty" <|
                    \_ ->
                        fill (Value.filled "")
                            |> withFieldError (Expect.equal (Just Error.RequiredFieldIsEmpty))
                , test "is nothing when value is valid" <|
                    \_ ->
                        fill (Value.filled "hello")
                            |> withFieldError (Expect.equal Nothing)
                , test "is ValidationFailed when value is filled and invalid" <|
                    \_ ->
                        fill (Value.filled invalidString)
                            |> withFieldError (Expect.equal (Just (Error.ValidationFailed "invalid input")))
                ]
            ]
        , describe "result"
            [ describe "error"
                [ test "RequiredFieldIsEmpty when value is blank" <|
                    \_ ->
                        fill Value.blank
                            |> .result
                            |> Expect.equal (Err ( Error.RequiredFieldIsEmpty, [] ))
                , test "RequiredFieldIsEmpty when value is filled but empty" <|
                    \_ ->
                        fill (Value.filled "")
                            |> .result
                            |> Expect.equal (Err ( Error.RequiredFieldIsEmpty, [] ))
                , test "ValidationFailed when value is filled and invalid" <|
                    \_ ->
                        fill (Value.filled invalidString)
                            |> .result
                            |> Expect.equal (Err ( Error.ValidationFailed "invalid input", [] ))
                ]
            , describe "correct"
                [ test "field output when value is valid" <|
                    \_ ->
                        fill (Value.filled "hello")
                            |> .result
                            |> Expect.equal (Ok "hello")
                ]
            ]
        , describe "isEmpty"
            [ test "True when value is blank" <|
                \_ ->
                    fill Value.blank
                        |> .isEmpty
                        |> Expect.equal True
            , test "True when value is filled but empty" <|
                \_ ->
                    fill (Value.filled "")
                        |> .isEmpty
                        |> Expect.equal True
            , test "False when value is filled and not empty" <|
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

        emailField =
            Form.emailField
                { parser =
                    \value ->
                        if String.contains "@" value then
                            Ok value
                        else
                            Err "The e-mail should contain a '@'"
                , value = .email
                , update = \value values -> { values | email = value }
                , attributes =
                    { label = "E-Mail"
                    , placeholder = "Type your e-mail..."
                    }
                }

        passwordField =
            Form.passwordField
                { parser =
                    \value ->
                        if String.length value >= 8 then
                            Ok value
                        else
                            Err "The password should have at least 8 characters"
                , value = .password
                , update = \value values -> { values | password = value }
                , attributes =
                    { label = "Password"
                    , placeholder = "Type your password..."
                    }
                }

        fill =
            Form.Base.fill form
    in
    describe "append"
        [ describe "fields"
            [ test "contains both fields" <|
                \_ ->
                    fill { email = Value.blank, password = Value.blank }
                        |> .fields
                        |> List.length
                        |> Expect.equal 2
            , test "contains the first error of each field" <|
                \_ ->
                    fill
                        { email = Value.filled "hello"
                        , password = Value.filled "123"
                        }
                        |> .fields
                        |> List.map Tuple.second
                        |> Expect.equal
                            [ Just (Error.ValidationFailed "The e-mail should contain a '@'")
                            , Just (Error.ValidationFailed "The password should have at least 8 characters")
                            ]
            , test "contains no errors when values are valid" <|
                \_ ->
                    fill
                        { email = Value.filled "hello@world.com"
                        , password = Value.filled "12345678"
                        }
                        |> .fields
                        |> List.map Tuple.second
                        |> Expect.equal [ Nothing, Nothing ]
            ]
        , describe "result"
            [ test "contains the correct output when values are valid" <|
                \_ ->
                    fill
                        { email = Value.filled "hello@world.com"
                        , password = Value.filled "12345678"
                        }
                        |> .result
                        |> Expect.equal (Ok ( "hello@world.com", "12345678" ))
            , test "contains the errors of the fields when values are invalid" <|
                \_ ->
                    fill
                        { email = Value.filled "hello"
                        , password = Value.filled "123"
                        }
                        |> .result
                        |> Expect.equal
                            (Err
                                ( Error.ValidationFailed "The e-mail should contain a '@'"
                                , [ Error.ValidationFailed "The password should have at least 8 characters" ]
                                )
                            )
            ]
        , describe "isEmpty"
            [ test "True when all fields are empty" <|
                \_ ->
                    fill { email = Value.blank, password = Value.filled "" }
                        |> .isEmpty
                        |> Expect.equal True
            , test "False when at least one field is not empty" <|
                \_ ->
                    fill { email = Value.blank, password = Value.filled "123" }
                        |> .isEmpty
                        |> Expect.equal False
            ]
        ]
