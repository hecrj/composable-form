module Data.Address exposing
    ( Address
    , City
    , Country
    , PostalCode
    , parseCity
    , parseCountry
    , parsePostalCode
    )


type alias Address =
    { country : Country
    , city : City
    , postalCode : PostalCode
    }



-- COUNTRY


type Country
    = Country String


parseCountry : String -> Result String Country
parseCountry =
    Ok << Country



-- CITY


type City
    = City String


parseCity : String -> Result String City
parseCity =
    Ok << City



-- POSTAL CODE


type PostalCode
    = PostalCode String


parsePostalCode : String -> Result String PostalCode
parsePostalCode =
    Ok << PostalCode
