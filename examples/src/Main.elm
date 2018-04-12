module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attributes
import Page.Login as Login
import Route exposing (Route)


type alias Model =
    Page


type Page
    = Home
    | Login Login.Model
    | NotFound


type Msg
    = RouteAccessed Route
    | Navigate Route
    | LoginMsg Login.Msg


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


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.header []
            [ Html.h1 [] [ Html.text "elm-form-draft" ]
            , Html.h2 [] [ Html.text "A draft of a form API for Elm" ]
            ]
        , Html.div [ Attributes.class "wrapper" ]
            [ case model of
                Home ->
                    viewHome

                Login loginModel ->
                    Login.view loginModel
                        |> Html.map LoginMsg

                NotFound ->
                    Html.text "Not found"
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

        Route.NotFound ->
            NotFound


viewHome : Html Msg
viewHome =
    let
        examples =
            [ ( "Login", Route.Login ) ]

        toItem ( name, route ) =
            Html.li []
                [ Html.a (Route.href Navigate route) [ Html.text name ] ]
    in
    Html.div []
        [ Html.h1 [] [ Html.text "Examples" ]
        , Html.ul []
            (List.map toItem examples)
        ]
