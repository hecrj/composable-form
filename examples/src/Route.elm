module Route exposing
    ( Key
    , Route(..)
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
import Url exposing (Url)
import Url.Parser as UrlParser exposing (Parser, map, s)


type Route
    = Top
    | Login
    | Signup
    | DynamicForm
    | VariableForm
    | ValidationStrategies
    | Composability
    | MultiStage
    | CustomFields
    | NotFound


type alias Key =
    Navigation.Key


parser : Parser (Route -> a) a
parser =
    UrlParser.oneOf
        [ map Top UrlParser.top
        , map Login (s "login")
        , map Signup (s "signup")
        , map DynamicForm (s "dynamic-form")
        , map VariableForm (s "variable-form")
        , map ValidationStrategies (s "validation-strategies")
        , map Composability (s "composability")
        , map MultiStage (s "multi-stage")
        , map CustomFields (s "custom-fields")
        ]


fromUrl : Url -> Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> UrlParser.parse parser
        |> Maybe.withDefault NotFound


program :
    { init : Route -> Navigation.Key -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : model -> Html msg
    , onExternalUrlRequest : String -> msg
    , onInternalUrlRequest : Route -> msg
    , onUrlChange : Route -> msg
    }
    -> Program () model msg
program { init, update, view, onInternalUrlRequest, onExternalUrlRequest, onUrlChange } =
    Browser.application
        { init = \flags -> fromUrl >> init
        , update = update
        , view = view >> List.singleton >> Browser.Document "composable-form - Build type-safe composable forms in Elm"
        , onUrlRequest =
            \request ->
                case request of
                    Browser.Internal url ->
                        onInternalUrlRequest (fromUrl url)

                    Browser.External url ->
                        onExternalUrlRequest url
        , onUrlChange = fromUrl >> onUrlChange
        , subscriptions = always Sub.none
        }


navigate : Navigation.Key -> Route -> Cmd msg
navigate key =
    Navigation.pushUrl key << toString


goBack : Navigation.Key -> Cmd msg
goBack key =
    Navigation.back key 1


href : (Route -> msg) -> Route -> List (Attribute msg)
href toMsg route =
    [ Attributes.attribute "href" (toString route)
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

                DynamicForm ->
                    [ "dynamic-form" ]

                VariableForm ->
                    [ "variable-form" ]

                ValidationStrategies ->
                    [ "validation-strategies" ]

                Composability ->
                    [ "composability" ]

                MultiStage ->
                    [ "multi-stage" ]

                CustomFields ->
                    [ "custom-fields" ]

                NotFound ->
                    [ "404" ]
    in
    "#/" ++ String.join "/" parts
