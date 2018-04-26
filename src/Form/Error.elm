module Form.Error
    exposing
        ( Error(..)
        )


type Error
    = EmptyField
    | ParserError String
