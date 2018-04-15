module Form.Field
    exposing
        ( CheckboxField
        , CheckboxFieldAttributes
        , Error(..)
        , Field(..)
        , SelectField
        , SelectFieldAttributes
        , State
        , TextField
        , TextFieldAttributes
        , TextFieldType(..)
        , map
        )

import Form.Value exposing (Value)


type Field values
    = Text (TextField values)
    | Checkbox (CheckboxField values)
    | Select (SelectField values)


map : (a -> b) -> Field a -> Field b
map f field =
    let
        mapUpdate ({ state } as field) =
            { field | state = { state | update = state.update >> f } }
    in
    case field of
        Text textField ->
            Text (mapUpdate textField)

        Checkbox checkboxField ->
            Checkbox (mapUpdate checkboxField)

        Select selectField ->
            Select (mapUpdate selectField)


type Error
    = EmptyError
    | ParserError String



-- STATE


type alias State a values =
    { value : Value a
    , update : a -> values
    }



-- TEXT


type alias TextField values =
    { type_ : TextFieldType
    , attributes : TextFieldAttributes
    , state : State String values
    }


type TextFieldType
    = RawText
    | TextArea
    | Password
    | Email


type alias TextFieldAttributes =
    { label : String
    , placeholder : String
    }



-- CHECKBOX


type alias CheckboxField values =
    { attributes : CheckboxFieldAttributes
    , state : State Bool values
    }


type alias CheckboxFieldAttributes =
    { label : String }



-- SELECT


type alias SelectField values =
    { options : List ( String, String )
    , attributes : SelectFieldAttributes
    , state : State String values
    }


type alias SelectFieldAttributes =
    { label : String
    , placeholder : String
    }
