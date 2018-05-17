module Form.Field.TextField
    exposing
        ( Attributes
        , TextField
        , form
        )

import Form.Base as Form exposing (Form)
import Form.Field.State exposing (State)


type alias TextField values =
    { attributes : Attributes
    , state : State String values
    }


type alias Attributes =
    { label : String
    , placeholder : String
    }


form :
    (TextField values -> field)
    -> Form.FieldConfig Attributes String values output
    -> Form values output field
form =
    Form.field
        { builder = TextField
        , isEmpty = String.isEmpty
        }
