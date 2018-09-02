module Data.Question exposing
    ( Body
    , Title
    , parseBody
    , parseTitle
    )

-- TITLE


type Title
    = Title String


parseTitle : String -> Result String Title
parseTitle title =
    if String.length title < 10 then
        Err "The question title must have at least 10 characters"

    else
        Ok (Title title)



-- BODY


type Body
    = Body String


parseBody : String -> Result String Body
parseBody body =
    if String.length body < 100 then
        Err "The question body must have at least 100 characters"

    else
        Ok (Body body)
