module Route
    exposing
        ( Route(..)
        , goBack
        , href
        , navigate
        , program
        )

import Browser
import Browser.Navigation as Navigation
import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder)
import Url.Parser as UrlParser exposing (Parser, map, s)


type Route
    = Top
    | Login
    | Signup
    | ValueReusability
    | ValidationStrategies
    | Composability
    | MultiStage
    | NotFound


parser : Parser (Route -> a) a
parser =
    UrlParser.oneOf
        [ map Top UrlParser.top
        , map Login (s "login")
        , map Signup (s "signup")
        , map ValueReusability (s "value-reusability")
        , map ValidationStrategies (s "validation-strategies")
        , map Composability (s "composability")
        , map MultiStage (s "multi-stage")
        ]


fromLocation : UrlParser.Url -> Route
fromLocation location =
    case UrlParser.parse parser location of
        Just route ->
            route

        Nothing ->
            NotFound


program :
    (Route -> msg)
    ->
        { init : Route -> ( model, Cmd msg )
        , update : msg -> model -> ( model, Cmd msg )
        , view : model -> Html msg
        }
    -> Program () model msg
program toMsg { init, update, view } =
    Browser.fullscreen
        { init = .url >> fromLocation >> init
        , update = update
        , view = view >> List.singleton >> Browser.Page "elm-form"
        , onNavigation = Just (fromLocation >> toMsg)
        , subscriptions = always Sub.none
        }


navigate : Route -> Cmd msg
navigate =
    Navigation.pushUrl << toString


goBack : Cmd msg
goBack =
    Navigation.back 1


href : (Route -> msg) -> Route -> List (Attribute msg)
href toMsg route =
    [ Attributes.attribute "href" (toString route)
    , Events.preventDefaultOn
        "click"
        (maybePreventDefault <| toMsg route)
    ]


toString : Route -> String
toString route =
    let
        parts =
            case route of
                Top ->
                    []

                Login ->
                    [ "login" ]

                Signup ->
                    [ "signup" ]

                ValueReusability ->
                    [ "value-reusability" ]

                ValidationStrategies ->
                    [ "validation-strategies" ]

                Composability ->
                    [ "composability" ]

                MultiStage ->
                    [ "multi-stage" ]

                NotFound ->
                    [ "404" ]
    in
    "/" ++ String.join "/" parts



-- FIX Ctrl/Cmd Click in Windows and Mac
-- https://github.com/elm-lang/html/issues/110
-- TODO: Review in Elm 0.19


preventDefault2 : Decoder Bool
preventDefault2 =
    Decode.map2
        invertedOr
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "metaKey" Decode.bool)


maybePreventDefault : msg -> Decoder ( msg, Bool )
maybePreventDefault msg =
    Decode.map (Tuple.pair msg) preventDefault2


invertedOr : Bool -> Bool -> Bool
invertedOr x y =
    not (x || y)
