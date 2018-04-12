module Form
    exposing
        ( CheckboxFieldConfig
        , FieldConfig
        , Form
        , Parser
        , SelectFieldConfig
        , append
        , appendMeta
        , checkboxField
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

import Form.Base as Base
import Form.Field as Field exposing (Field)
import List.Nonempty exposing (Nonempty)


type alias Form values output =
    Base.Form values output (Field values)


type alias Parser a b =
    Base.Parser a b


fields : Form values output -> values -> List ( Field values, Maybe Field.Error )
fields =
    Base.fields


result : Form values output -> values -> Result (Nonempty Field.Error) output
result =
    Base.result



-- CONSTRUCTORS


empty : output -> Form values output
empty =
    Base.empty


type alias FieldConfig attrs values input output =
    Base.FieldConfig attrs values input output



-- TEXT FIELD


textField : FieldConfig Field.TextFieldAttributes values String output -> Form values output
textField =
    Base.textField Field.Text


textAreaField : FieldConfig Field.TextFieldAttributes values String output -> Form values output
textAreaField =
    Base.textAreaField Field.Text



-- EMAIL FIELD


emailField : FieldConfig Field.TextFieldAttributes values String output -> Form values output
emailField =
    Base.emailField Field.Text



-- PASSWORD FIELD


passwordField : FieldConfig Field.TextFieldAttributes values String output -> Form values output
passwordField =
    Base.passwordField Field.Text



-- CHECKBOX FIELD


type alias CheckboxFieldConfig values output =
    Base.CheckboxFieldConfig values output


checkboxField : CheckboxFieldConfig values output -> Form values output
checkboxField =
    Base.checkboxField Field.Checkbox



-- SELECT FIELD


type alias SelectFieldConfig values output =
    Base.SelectFieldConfig values output


selectField : SelectFieldConfig values output -> Form values output
selectField =
    Base.selectField Field.Select



-- OPERATIONS


optional : Form values output -> Form values (Maybe output)
optional =
    Base.optional


append : Form values a -> Form values (a -> b) -> Form values b
append =
    Base.append


appendMeta : Form values a -> Form values b -> Form values b
appendMeta =
    Base.appendMeta
