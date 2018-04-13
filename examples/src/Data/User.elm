module Data.User
    exposing
        ( FavoriteLanguage(..)
        , Name
        , Password
        , favoriteLanguageToString
        , favoriteLanguages
        , parseFavoriteLanguage
        , parseName
        , parsePassword
        )

import Dict


-- NAME


type Name
    = Name String


parseName : String -> Result String Name
parseName name =
    if String.length name < 2 then
        Err "The name must have at least 2 characters"
    else
        Ok (Name name)



-- PASSWORD


type Password
    = Password String


parsePassword : String -> Result String Password
parsePassword password =
    if String.length password < 8 then
        Err "The password must have at least 8 characters"
    else
        Ok (Password password)



-- FAVORITE LANGUAGE


type FavoriteLanguage
    = Elm
    | Javascript
    | Other


favoriteLanguages : List FavoriteLanguage
favoriteLanguages =
    [ Elm, Javascript, Other ]


parseFavoriteLanguage : String -> Result String FavoriteLanguage
parseFavoriteLanguage language =
    favoriteLanguages
        |> List.map (\lang -> ( favoriteLanguageToString lang, lang ))
        |> Dict.fromList
        |> Dict.get language
        |> Maybe.map Ok
        |> Maybe.withDefault (Err "Invalid language")


favoriteLanguageToString : FavoriteLanguage -> String
favoriteLanguageToString language =
    case language of
        Elm ->
            "elm"

        Javascript ->
            "js"

        Other ->
            "other"
