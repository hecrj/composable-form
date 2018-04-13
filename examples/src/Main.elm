module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attributes
import Page.Login as Login
import Page.ReusingValues as ReusingValues
import Page.Signup as Signup
import Route exposing (Route)


type alias Model =
    Page


type Page
    = Home
    | Login Login.Model
    | Signup Signup.Model
    | ReusingValues ReusingValues.Model
    | NotFound


type Msg
    = RouteAccessed Route
    | Navigate Route
    | LoginMsg Login.Msg
    | SignupMsg Signup.Msg
    | ReusingValuesMsg ReusingValues.Msg


main : Program Never Model Msg
main =
    Route.program
        RouteAccessed
        { init = init
        , update = update
        , view = view
        }


init : Route -> ( Model, Cmd Msg )
init route =
    ( fromRoute route, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouteAccessed route ->
            ( fromRoute route, Cmd.none )

        Navigate route ->
            ( model, Route.navigate route )

        LoginMsg loginMsg ->
            case model of
                Login loginModel ->
                    ( Login (Login.update loginMsg loginModel), Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignupMsg signupMsg ->
            case model of
                Signup signupModel ->
                    ( Signup (Signup.update signupMsg signupModel), Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ReusingValuesMsg subMsg ->
            case model of
                ReusingValues subModel ->
                    ( ReusingValues (ReusingValues.update subMsg subModel), Cmd.none )

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.header []
            [ Html.h1 [] [ Html.text "elm-wip-form" ]
            , Html.h2 [] [ Html.text "A WIP form API for Elm" ]
            , Html.div []
                [ Html.a (Route.href Navigate Route.Top)
                    [ Html.text "Examples" ]
                , Html.a [ Attributes.href repositoryUrl ]
                    [ Html.text "Repository" ]
                , Html.a [ Attributes.href "https://discourse.elm-lang.org/t/a-form-api-idea-proposal/1121" ]
                    [ Html.text "Discussion" ]
                ]
            ]
        , Html.div [ Attributes.class "wrapper" ]
            [ case model of
                Home ->
                    viewHome

                Login loginModel ->
                    Login.view loginModel
                        |> Html.map LoginMsg

                Signup signupModel ->
                    Signup.view signupModel
                        |> Html.map SignupMsg

                ReusingValues subModel ->
                    ReusingValues.view subModel
                        |> Html.map ReusingValuesMsg

                NotFound ->
                    Html.text "Not found"
            ]
        , Html.footer []
            [ case pageCodeUri model of
                Just uri ->
                    Html.a
                        [ Attributes.href (repositoryUrl ++ "/blob/master/examples/src/Page" ++ uri)
                        , Attributes.target "_blank"
                        ]
                        [ Html.text "Code" ]

                Nothing ->
                    Html.text ""
            ]
        ]



-- HELPERS


fromRoute : Route -> Page
fromRoute route =
    case route of
        Route.Top ->
            Home

        Route.Login ->
            Login Login.init

        Route.Signup ->
            Signup Signup.init

        Route.ReusingValues ->
            ReusingValues ReusingValues.init

        Route.NotFound ->
            NotFound


viewHome : Html Msg
viewHome =
    let
        examples =
            [ ( "Login", Route.Login )
            , ( "Signup", Route.Signup )
            , ( "Reusing values", Route.ReusingValues )
            ]

        toItem ( name, route ) =
            Html.li []
                [ Html.a (Route.href Navigate route) [ Html.text name ] ]
    in
    Html.div []
        [ Html.h1 [] [ Html.text "Examples" ]
        , Html.ul []
            (List.map toItem examples)
        ]


repositoryUrl : String
repositoryUrl =
    "https://github.com/hecrj/elm-wip-form"


pageCodeUri : Page -> Maybe String
pageCodeUri page =
    case page of
        Home ->
            Nothing

        Login _ ->
            Just "/Login.elm"

        Signup _ ->
            Just "/Signup.elm"

        ReusingValues _ ->
            Just "/ReusingValues.elm"

        NotFound ->
            Nothing
