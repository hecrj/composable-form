module Form
    exposing
        ( Field(..)
        , Form
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
import Form.Error exposing (Error)
import Form.Field.CheckboxField as CheckboxField exposing (CheckboxField)
import Form.Field.SelectField as SelectField exposing (SelectField)
import Form.Field.TextField as TextField exposing (TextField)
import List.Nonempty exposing (Nonempty)


type alias Form values output =
    Base.Form values output (Field values)


fields : Form values output -> values -> List ( Field values, Maybe Error )
fields =
    Base.fields


result : Form values output -> values -> Result (Nonempty Error) output
result =
    Base.result



-- Constructors


empty : output -> Form values output
empty =
    Base.empty



-- Operations


optional : Form values output -> Form values (Maybe output)
optional =
    Base.optional


append : Form values a -> Form values (a -> b) -> Form values b
append =
    Base.append


appendMeta : Form values a -> Form values b -> Form values b
appendMeta =
    Base.appendMeta



-- Field


type Field values
    = Text (TextField values)
    | Checkbox (CheckboxField values)
    | Select (SelectField values)



-- Text fields


textField : Base.FieldConfig TextField.Attributes String values output -> Form values output
textField =
    TextField.text Text


textAreaField : Base.FieldConfig TextField.Attributes String values output -> Form values output
textAreaField =
    TextField.textArea Text


passwordField : Base.FieldConfig TextField.Attributes String values output -> Form values output
passwordField =
    TextField.password Text


emailField : Base.FieldConfig TextField.Attributes String values output -> Form values output
emailField =
    TextField.email Text



-- Checkbox field


checkboxField : Base.FieldConfig CheckboxField.Attributes Bool values output -> Form values output
checkboxField =
    CheckboxField.build Checkbox



-- Select field


selectField : Base.FieldConfig SelectField.Attributes String values output -> Form values output
selectField =
    SelectField.build Select
