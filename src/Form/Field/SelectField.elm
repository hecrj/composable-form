module Form.Field.SelectField exposing (Attributes, SelectField, build)

import Form.Base as Form exposing (Form)
import Form.Field.State exposing (State)


type alias SelectField values =
    { attributes : Attributes
    , state : State String values
    }


type alias Attributes =
    { label : String
    , placeholder : String
    , options : List ( String, String )
    }


build :
    (SelectField values -> field)
    -> Form.FieldConfig Attributes String values output
    -> Form values output field
build =
    Form.field { builder = SelectField, isEmpty = String.isEmpty }
