module Main exposing (main)

import Browser.Navigation as Navigation
import Html exposing (Html)
import Html.Attributes as Attributes
import Page.Composability.Simple as Composability
import Page.CustomFields as CustomFields
import Page.DynamicForm as DynamicForm
import Page.Login as Login
import Page.MultiStage as MultiStage
import Page.Signup as Signup
import Page.ValidationStrategies as ValidationStrategies
import Route exposing (Route)
import View


type alias Model =
    { page : Page
    , key : Route.Key
    }


type Page
    = Home
    | Login Login.Model
    | Signup Signup.Model
    | DynamicForm DynamicForm.Model
    | ValidationStrategies ValidationStrategies.Model
    | Composability Composability.Model
    | MultiStage MultiStage.Model
    | CustomFields CustomFields.Model
    | NotFound


type Msg
    = RouteAccessed Route
    | Navigate Route
    | LoadExternalUrl String
    | LoginMsg Login.Msg
    | SignupMsg Signup.Msg
    | DynamicFormMsg DynamicForm.Msg
    | ValidationStrategiesMsg ValidationStrategies.Msg
    | ComposabilityMsg Composability.Msg
    | MultiStageMsg MultiStage.Msg
    | CustomFieldsMsg CustomFields.Msg


main : Program () Model Msg
main =
    Route.program
        { init = init
        , update = update
        , view = view
        , onExternalUrlRequest = LoadExternalUrl
        , onInternalUrlRequest = Navigate
        , onUrlChange = RouteAccessed
        }


init : Route -> Route.Key -> ( Model, Cmd Msg )
init route key =
    ( { page = fromRoute route
      , key = key
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RouteAccessed route ->
            ( { model | page = fromRoute route }, Cmd.none )

        Navigate route ->
            ( model, Route.navigate model.key route )

        LoadExternalUrl string ->
            ( model, Navigation.load string )

        LoginMsg loginMsg ->
            case model.page of
                Login loginModel ->
                    ( { model | page = Login (Login.update loginMsg loginModel) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        SignupMsg signupMsg ->
            case model.page of
                Signup signupModel ->
                    Signup.update signupMsg signupModel
                        |> Tuple.mapFirst Signup
                        |> Tuple.mapFirst (\page -> { model | page = page })
                        |> Tuple.mapSecond (Cmd.map SignupMsg)

                _ ->
                    ( model, Cmd.none )

        DynamicFormMsg subMsg ->
            case model.page of
                DynamicForm subModel ->
                    ( { model | page = DynamicForm (DynamicForm.update subMsg subModel) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ValidationStrategiesMsg subMsg ->
            case model.page of
                ValidationStrategies subModel ->
                    ( { model | page = ValidationStrategies (ValidationStrategies.update subMsg subModel) }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ComposabilityMsg subMsg ->
            case model.page of
                Composability subModel ->
                    ( { model | page = Composability (Composability.update subMsg subModel) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        MultiStageMsg subMsg ->
            case model.page of
                MultiStage subModel ->
                    MultiStage.update subMsg subModel
                        |> Tuple.mapFirst MultiStage
                        |> Tuple.mapFirst (\page -> { model | page = page })
                        |> Tuple.mapSecond (Cmd.map MultiStageMsg)

                _ ->
                    ( model, Cmd.none )

        CustomFieldsMsg subMsg ->
            case model.page of
                CustomFields signupModel ->
                    CustomFields.update subMsg signupModel
                        |> Tuple.mapFirst CustomFields
                        |> Tuple.mapFirst (\page -> { model | page = page })
                        |> Tuple.mapSecond (Cmd.map CustomFieldsMsg)

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.header []
            [ Html.h1 [] [ Html.text "composable-form" ]
            , Html.h2 [] [ Html.text "Build type-safe composable forms in Elm" ]
            , Html.div []
                [ Html.a (Route.href Navigate Route.Top)
                    [ Html.text "Examples" ]
                , Html.a [ Attributes.href View.repositoryUrl ]
                    [ Html.text "Repository" ]
                ]
            ]
        , Html.div [ Attributes.class "wrapper" ]
            [ case model.page of
                Home ->
                    viewHome

                Login loginModel ->
                    Login.view loginModel
                        |> Html.map LoginMsg

                Signup signupModel ->
                    Signup.view signupModel
                        |> Html.map SignupMsg

                DynamicForm subModel ->
                    DynamicForm.view subModel
                        |> Html.map DynamicFormMsg

                ValidationStrategies subModel ->
                    ValidationStrategies.view subModel
                        |> Html.map ValidationStrategiesMsg

                Composability subModel ->
                    Composability.view subModel
                        |> Html.map ComposabilityMsg

                MultiStage subModel ->
                    MultiStage.view subModel
                        |> Html.map MultiStageMsg

                CustomFields subModel ->
                    CustomFields.view subModel
                        |> Html.map CustomFieldsMsg

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

        Route.Signup ->
            Signup Signup.init

        Route.DynamicForm ->
            DynamicForm DynamicForm.init

        Route.ValidationStrategies ->
            ValidationStrategies ValidationStrategies.init

        Route.Composability ->
            Composability Composability.init

        Route.MultiStage ->
            MultiStage MultiStage.init

        Route.CustomFields ->
            CustomFields CustomFields.init

        Route.NotFound ->
            NotFound


viewHome : Html Msg
viewHome =
    let
        examples =
            [ ( "Login"
              , Route.Login
              , "A simple login form with 3 fields."
              )
            , ( "Signup"
              , Route.Signup
              , "A select field and external form errors."
              )
            , ( "Dynamic form"
              , Route.DynamicForm
              , "A form that changes dynamically based on its own values."
              )
            , ( "Validation strategies"
              , Route.ValidationStrategies
              , "Two different validation strategies: validation on submit and validation on blur."
              )
            , ( "Composability"
              , Route.Composability
              , "An address form embedded in a bigger form."
              )
            , ( "Multiple stages"
              , Route.MultiStage
              , "Custom form view that allows the user to fill a form in multiple stages."
              )
            , ( "Custom fields"
              , Route.CustomFields
              , "An example that showcases how custom fields can be implemented to suit your needs."
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
