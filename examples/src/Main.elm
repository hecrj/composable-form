module Main exposing (main)

import Html exposing (Html)
import Html.Attributes as Attributes
import Page.Composability.Simple as Composability
import Page.Login as Login
import Page.MultiStage as MultiStage
import Page.Signup as Signup
import Page.ValidationStrategies as ValidationStrategies
import Page.ValueReusability as ValueReusability
import Route exposing (Route)


type alias Model =
    Page


type Page
    = Home
    | Login Login.Model
    | Signup Signup.Model
    | ValueReusability ValueReusability.Model
    | ValidationStrategies ValidationStrategies.Model
    | Composability Composability.Model
    | MultiStage MultiStage.Model
    | NotFound


type Msg
    = RouteAccessed Route
    | Navigate Route
    | LoginMsg Login.Msg
    | SignupMsg Signup.Msg
    | ValueReusabilityMsg ValueReusability.Msg
    | ValidationStrategiesMsg ValidationStrategies.Msg
    | ComposabilityMsg Composability.Msg
    | MultiStageMsg MultiStage.Msg


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
                    Signup.update signupMsg signupModel
                        |> Tuple.mapFirst Signup
                        |> Tuple.mapSecond (Cmd.map SignupMsg)

                _ ->
                    ( model, Cmd.none )

        ValueReusabilityMsg subMsg ->
            case model of
                ValueReusability subModel ->
                    ( ValueReusability (ValueReusability.update subMsg subModel), Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ValidationStrategiesMsg subMsg ->
            case model of
                ValidationStrategies subModel ->
                    ( ValidationStrategies (ValidationStrategies.update subMsg subModel)
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ComposabilityMsg subMsg ->
            case model of
                Composability subModel ->
                    ( Composability (Composability.update subMsg subModel), Cmd.none )

                _ ->
                    ( model, Cmd.none )

        MultiStageMsg subMsg ->
            case model of
                MultiStage subModel ->
                    MultiStage.update subMsg subModel
                        |> Tuple.mapFirst MultiStage
                        |> Tuple.mapSecond (Cmd.map MultiStageMsg)

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

                ValueReusability subModel ->
                    ValueReusability.view subModel
                        |> Html.map ValueReusabilityMsg

                ValidationStrategies subModel ->
                    ValidationStrategies.view subModel
                        |> Html.map ValidationStrategiesMsg

                Composability subModel ->
                    Composability.view subModel
                        |> Html.map ComposabilityMsg

                MultiStage subModel ->
                    MultiStage.view subModel
                        |> Html.map MultiStageMsg

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

        Route.ValueReusability ->
            ValueReusability ValueReusability.init

        Route.ValidationStrategies ->
            ValidationStrategies ValidationStrategies.init

        Route.Composability ->
            Composability Composability.init

        Route.MultiStage ->
            MultiStage MultiStage.init

        Route.NotFound ->
            NotFound


viewHome : Html Msg
viewHome =
    let
        examples =
            [ ( "Login", Route.Login, "Shows a simple login form with 3 fields." )
            , ( "Signup"
              , Route.Signup
              , "Showcases a select field, a meta field and external form errors."
              )
            , ( "Value reusability"
              , Route.ValueReusability
              , "Shows how field values are decoupled from any form, and how they can be reused with a single source of truth. It also showcases an optional field."
              )
            , ( "Validation strategies"
              , Route.ValidationStrategies
              , "Showcases two different validation strategies: validation on submit and validation on blur."
              )
            , ( "Composability"
              , Route.Composability
              , "Shows an address form embedded in a bigger form."
              )
            , ( "Multiple stages"
              , Route.MultiStage
              , "Showcases a form that is filled in multiple stages."
              )
            ]

        toItem ( name, route, description ) =
            Html.li []
                [ Html.a (Route.href Navigate route) [ Html.text name ]
                , Html.p [] [ Html.text description ]
                ]
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

        ValueReusability _ ->
            Just "/ValueReusability.elm"

        ValidationStrategies _ ->
            Just "/ValidationStrategies.elm"

        Composability _ ->
            Just "/Composability/"

        MultiStage _ ->
            Just "/MultiStage.elm"

        NotFound ->
            Nothing
