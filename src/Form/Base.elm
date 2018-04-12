module Form.Base
    exposing
        ( CheckboxFieldConfig
        , FieldConfig
        , Form
        , Parser
        , SelectFieldConfig
        , append
        , appendMeta
        , checkboxField
        , custom
        , emailField
        , empty
        , fields
        , optional
        , passwordField
        , result
        , selectField
        , textAreaField
        , textField
        )

import Form.Field as Field exposing (Field)
import Form.Value as Value exposing (Value)
import List.Nonempty exposing (Nonempty)


-- FORM


type Form values output field
    = Form (List (FieldBuilder values field)) (values -> Result (Nonempty Field.Error) output)


type alias FieldBuilder values field =
    values -> ( field, Maybe Field.Error )


type alias Parser a b =
    a -> Result String b


fields : Form values output field -> values -> List ( field, Maybe Field.Error )
fields (Form fields _) values =
    List.map (\builder -> builder values) fields


result : Form values output field -> values -> Result (Nonempty Field.Error) output
result (Form _ parser) =
    parser



-- CONSTRUCTORS


empty : output -> Form values output custom
empty output =
    Form [] (always (Ok output))


appendMeta : Form values a custom -> Form values b custom -> Form values b custom
appendMeta (Form newFields newOutput) (Form fields output) =
    Form (fields ++ newFields)
        (\values ->
            newOutput values
                |> Result.andThen (always (output values))
        )



-- TEXT FIELD


textField : (Field.TextField values -> field) -> FieldConfig Field.TextFieldAttributes values String output -> Form values output field
textField =
    custom (Field.TextField Field.RawText) String.isEmpty



-- TEXTAREA FIELD


textAreaField : (Field.TextField values -> field) -> FieldConfig Field.TextFieldAttributes values String output -> Form values output field
textAreaField =
    custom (Field.TextField Field.TextArea) String.isEmpty



-- EMAIL FIELD


emailField : (Field.TextField values -> field) -> FieldConfig Field.TextFieldAttributes values String output -> Form values output field
emailField =
    custom (Field.TextField Field.Email) String.isEmpty



-- PASSWORD FIELD


passwordField : (Field.TextField values -> field) -> FieldConfig Field.TextFieldAttributes values String output -> Form values output field
passwordField =
    custom (Field.TextField Field.Password) String.isEmpty



-- CHECKBOX FIELD


type alias CheckboxFieldConfig values output =
    { parser : Parser Bool output
    , value : values -> Value Bool
    , update : Value Bool -> values -> values
    , attributes : Field.CheckboxFieldAttributes
    }


checkboxField : (Field.CheckboxField values -> field) -> CheckboxFieldConfig values output -> Form values output field
checkboxField toField { parser, value, update, attributes } =
    custom Field.CheckboxField
        (always False)
        toField
        { parser = parser
        , value = value >> Value.withDefault False
        , update = update
        , attributes = attributes
        }



-- SELECT FIELD


type alias SelectFieldConfig values output =
    { parser : Parser String output
    , value : values -> Value String
    , update : Value String -> values -> values
    , options : List ( String, String )
    , attributes : Field.SelectFieldAttributes
    }


selectField : (Field.SelectField values -> field) -> SelectFieldConfig values output -> Form values output field
selectField toField { parser, value, update, options, attributes } =
    custom (Field.SelectField options)
        String.isEmpty
        toField
        { parser = parser
        , value = value
        , update = update
        , attributes = attributes
        }



-- HELPERS


type alias FieldConfig attrs values input output =
    { parser : Parser input output
    , value : values -> Value input
    , update : Value input -> values -> values
    , attributes : attrs
    }


custom : (attrs -> Field.State a values -> config) -> (a -> Bool) -> (config -> field) -> FieldConfig attrs values a b -> Form values b field
custom factory isEmpty constructor config =
    let
        requiredParser maybeValue =
            case maybeValue of
                Nothing ->
                    Err (List.Nonempty.fromElement Field.EmptyError)

                Just value ->
                    if isEmpty value then
                        Err (List.Nonempty.fromElement Field.EmptyError)
                    else
                        config.parser value
                            |> Result.mapError (Field.ParserError >> List.Nonempty.fromElement)

        parse =
            config.value >> Value.raw >> requiredParser

        update values newValue =
            let
                value =
                    config.value values

                result =
                    config.parser newValue
            in
            value
                |> Value.change newValue
                |> flip config.update values

        error values =
            case parse values of
                Ok _ ->
                    Nothing

                Err errors ->
                    Just (List.Nonempty.head errors)

        attributes values =
            { value = config.value values
            , update = update values
            }

        builder values =
            ( factory config.attributes (attributes values) |> constructor, error values )
    in
    Form [ builder ] parse



-- OPERATIONS


optional : Form values output custom -> Form values (Maybe output) custom
optional (Form builders output) =
    let
        optionalBuilder builder values =
            case builder values of
                ( field, Just Field.EmptyError ) ->
                    ( field, Nothing )

                result ->
                    result

        optionalOutput values =
            case output values of
                Ok value ->
                    Ok (Just value)

                Err errors ->
                    if List.Nonempty.all ((==) Field.EmptyError) errors then
                        Ok Nothing
                    else
                        Err errors
    in
    Form (List.map optionalBuilder builders) optionalOutput


append : Form values a custom -> Form values (a -> b) custom -> Form values b custom
append (Form newFields newOutput) (Form fields output) =
    Form (fields ++ newFields)
        (\values ->
            case output values of
                Ok f ->
                    newOutput values
                        |> Result.map f

                Err errors ->
                    case newOutput values of
                        Ok _ ->
                            Err errors

                        Err newErrors ->
                            Err (List.Nonempty.append errors newErrors)
        )
