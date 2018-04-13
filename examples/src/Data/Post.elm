module Data.Post
    exposing
        ( Body
        , parseBody
        )


type Body
    = Body String


parseBody : String -> Result String Body
parseBody body =
    if String.length body < 10 then
        Err "The post body must have at least 10 characters"
    else
        Ok (Body body)
