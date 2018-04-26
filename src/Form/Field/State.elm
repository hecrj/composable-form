module Form.Field.State exposing (State)

import Form.Value exposing (Value)


type alias State a values =
    { value : Value a
    , update : a -> values
    }
