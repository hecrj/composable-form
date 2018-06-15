module Base exposing (field, succeed)

import Expect exposing (Expectation)
import Form.Base
import Form.Error as Error
import Form.Value as Value
import Test exposing (..)


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

        expectFieldAndError fn result =
            case result.fields of
                [ fieldAndError_ ] ->
                    fn fieldAndError_

                _ ->
                    Expect.fail "fields do not contain a single field"

        expectField fn =
            expectFieldAndError (Tuple.first >> fn)

        expectFieldError fn =
            expectFieldAndError (Tuple.second >> fn)
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
                        |> expectField (.value >> Expect.equal value)
            , test "builds the field with an update helper" <|
                \_ ->
                    let
                        value =
                            Value.filled "hello"

                        newValue =
                            "hello world"
                    in
                    fill value
                        |> expectField
                            (\field_ ->
                                field_.update newValue
                                    |> Expect.equal (Value.update newValue value)
                            )
            , test "builds the field with its attributes" <|
                \_ ->
                    fill Value.blank
                        |> expectField (.attributes >> Expect.equal attributes)
            , describe "field error"
                [ test "is RequiredFieldIsEmpty when value is blank" <|
                    \_ ->
                        fill Value.blank
                            |> expectFieldError (Expect.equal (Just Error.RequiredFieldIsEmpty))
                , test "is RequiredFieldIsEmpty when value is filled but empty" <|
                    \_ ->
                        fill (Value.filled "")
                            |> expectFieldError (Expect.equal (Just Error.RequiredFieldIsEmpty))
                , test "is nothing when value is valid" <|
                    \_ ->
                        fill (Value.filled "hello")
                            |> expectFieldError (Expect.equal Nothing)
                , test "is ValidationFailed when value is filled and invalid" <|
                    \_ ->
                        fill (Value.filled invalidString)
                            |> expectFieldError (Expect.equal (Just (Error.ValidationFailed "invalid input")))
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
