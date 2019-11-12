module Form.Base.MultiselectField exposing
    ( Attributes
    , MultiselectField
    , form
    )

import Form.Base as Form exposing (Form)
import Multiselect


type alias MultiselectField values =
    { value : Multiselect.Model
    , update : Multiselect.Model -> values
    , attributes : Attributes
    }



--  Field Attributes Multiselect.Model values


type alias Attributes =
    { label : String
    , placeholder : String
    , options : List ( String, String )
    }


form :
    (MultiselectField values -> field)
    -> Form.FieldConfig Attributes Multiselect.Model values output
    -> Form values output field
form =
    Form.field { isEmpty = \value -> List.isEmpty <| Multiselect.getSelectedValues value }


populateValues : List ( String, String ) -> List ( String, String ) -> Multiselect.Model -> Multiselect.Model
populateValues values preselected model =
    Multiselect.populateValues model values preselected
