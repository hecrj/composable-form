module Route
    exposing
        ( Route(..)
        , goBack
        , href
        , navigate
        , program
        )

import Html exposing (Attribute, Html)
import Html.Attributes as Attributes
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder)
import Navigation
import UrlParser exposing (Parser, map, s)


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


fromLocation : Navigation.Location -> Route
fromLocation location =
    case UrlParser.parseHash parser location of
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
    -> Program Never model msg
program toMsg { init, update, view } =
    Navigation.program
        (fromLocation >> toMsg)
        { init = fromLocation >> init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


navigate : Route -> Cmd msg
navigate =
    Navigation.newUrl << toString


goBack : Cmd msg
goBack =
    Navigation.back 1


href : (Route -> msg) -> Route -> List (Attribute msg)
href toMsg route =
    [ Attributes.attribute "href" (toString route)
    , Events.onWithOptions
        "click"
        { stopPropagation = False, preventDefault = True }
        (preventDefault2
            |> Decode.andThen (maybePreventDefault <| toMsg route)
        )
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
    "#/" ++ String.join "/" parts



-- FIX Ctrl/Cmd Click in Windows and Mac
-- https://github.com/elm-lang/html/issues/110
-- TODO: Review in Elm 0.19


preventDefault2 : Decoder Bool
preventDefault2 =
    Decode.map2
        invertedOr
        (Decode.field "ctrlKey" Decode.bool)
        (Decode.field "metaKey" Decode.bool)


maybePreventDefault : msg -> Bool -> Decoder msg
maybePreventDefault msg preventDefault =
    case preventDefault of
        True ->
            Decode.succeed msg

        False ->
            Decode.fail "Normal link"


invertedOr : Bool -> Bool -> Bool
invertedOr x y =
    not (x || y)
