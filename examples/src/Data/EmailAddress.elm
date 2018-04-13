module Data.EmailAddress
    exposing
        ( EmailAddress
        , parse
        )


type EmailAddress
    = EmailAddress String


parse : String -> Result String EmailAddress
parse str =
    if String.contains "@" str then
        Ok (EmailAddress str)
    else
        Err "The e-mail address must contain a '@' symbol"
