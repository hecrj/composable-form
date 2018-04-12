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
        Err "invalid e-mail address"
