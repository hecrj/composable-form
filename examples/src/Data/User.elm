module Data.User
    exposing
        ( FavoriteLanguage(..)
        , Name
        , Password
        , User
        , favoriteLanguageToString
        , favoriteLanguages
        , nameToString
        , parseFavoriteLanguage
        , parseName
        , parsePassword
        , passwordLength
        , signUp
        )

import Data.EmailAddress as EmailAddress exposing (EmailAddress)
import Dict
import Process
import Task exposing (Task)
import Time


type alias User =
    { email : EmailAddress
    , name : Name
    , favoriteLanguage : FavoriteLanguage
    }



-- NAME


type Name
    = Name String


nameToString : Name -> String
nameToString (Name name) =
    name


parseName : String -> Result String Name
parseName name =
    if String.length name < 2 then
        Err "The name must have at least 2 characters"
    else
        Ok (Name name)



-- PASSWORD


type Password
    = Password String


passwordLength : Password -> Int
passwordLength (Password password) =
    String.length password


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



-- REQUESTS


signUp : EmailAddress -> Name -> Password -> FavoriteLanguage -> Task String User
signUp email name password favoriteLanguage =
    let
        response =
            if EmailAddress.toString email == "free@email.com" then
                Task.succeed (User email name favoriteLanguage)
            else
                Task.fail "The e-mail address is taken. Try this one: free@email.com"
    in
    -- Here we simulate an HTTP request to some backend server
    Process.sleep 1000
        |> Task.andThen (always response)
