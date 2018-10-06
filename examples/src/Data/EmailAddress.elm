module Data.EmailAddress exposing
    ( EmailAddress
    , parse
    , toString
    )


type EmailAddress
    = EmailAddress String


toString : EmailAddress -> String
toString (EmailAddress email) =
    email


parse : String -> Result String EmailAddress
parse str =
    if String.contains "@" str then
        Ok (EmailAddress str)

    else
        Err "The e-mail address must contain a '@' symbol"
