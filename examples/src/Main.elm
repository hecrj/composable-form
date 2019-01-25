module Main exposing (main)

import Browser.Navigation as Navigation
import Form.View
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events
import Page.Composability.Simple as Composability
import Page.CustomFields as CustomFields
import Page.DynamicForm as DynamicForm
import Page.FormList as FormList
import Page.Login as Login
import Page.Signup as Signup
import Page.ValidationStrategies as ValidationStrategies
import Route exposing (Route)
import View exposing (FormView(..))


type alias Model =
    { page : Page
    , key : Route.Key
    , formView : FormView
    }


type Page
    = Home
    | Login Login.Model
    | Signup Signup.Model
    | DynamicForm DynamicForm.Model
    | FormList FormList.Model
    | ValidationStrategies ValidationStrategies.Model
    | Composability Composability.Model
    | CustomFields CustomFields.Model
    | NotFound


type Msg
    = RouteAccessed Route
    | Navigate Route
    | LoadExternalUrl String
    | SelectedFormView FormView
    | LoginMsg Login.Msg
    | SignupMsg Signup.Msg
    | DynamicFormMsg DynamicForm.Msg
    | FormListMsg FormList.Msg
    | ValidationStrategiesMsg ValidationStrategies.Msg
    | ComposabilityMsg Composability.Msg
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
      , formView = Default
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

        SelectedFormView formView ->
            ( { model | formView = formView }, Cmd.none )

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

        FormListMsg subMsg ->
            case model.page of
                FormList subModel ->
                    ( { model | page = FormList (FormList.update subMsg subModel) }, Cmd.none )

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
                    Login.view model.formView loginModel
                        |> Html.map LoginMsg

                Signup signupModel ->
                    Signup.view model.formView signupModel
                        |> Html.map SignupMsg

                DynamicForm subModel ->
                    DynamicForm.view model.formView subModel
                        |> Html.map DynamicFormMsg

                FormList subModel ->
                    FormList.view subModel
                        |> Html.map FormListMsg

                ValidationStrategies subModel ->
                    ValidationStrategies.view model.formView subModel
                        |> Html.map ValidationStrategiesMsg

                Composability subModel ->
                    Composability.view model.formView subModel
                        |> Html.map ComposabilityMsg

                CustomFields subModel ->
                    CustomFields.view subModel
                        |> Html.map CustomFieldsMsg

                NotFound ->
                    Html.text "Not found"
            , if model.page /= Home && model.page /= NotFound then
                viewStrategySelector model.formView

              else
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

        Route.DynamicForm ->
            DynamicForm DynamicForm.init

        Route.FormList ->
            FormList FormList.init

        Route.ValidationStrategies ->
            ValidationStrategies ValidationStrategies.init

        Route.Composability ->
            Composability Composability.init

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
            , ( "Form list"
              , Route.FormList
              , "A variable list of forms that can be added and deleted."
              )
            , ( "Validation strategies"
              , Route.ValidationStrategies
              , "Two different validation strategies: validation on submit and validation on blur."
              )
            , ( "Composability"
              , Route.Composability
              , "An address form embedded in a bigger form."
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


viewStrategySelector : FormView -> Html Msg
viewStrategySelector formView =
    Html.fieldset []
        [ Html.legend [] [ Html.text "View strategy" ]
        , radio (SelectedFormView Default) (formView == Default) "Default"
        , radio (SelectedFormView Ui) (formView == Ui) "elm-ui"
        ]


radio : msg -> Bool -> String -> Html msg
radio msg isChecked name =
    Html.label []
        [ Html.input
            [ Attributes.type_ "radio"
            , Html.Events.onClick msg
            , Attributes.checked isChecked
            ]
            []
        , Html.text name
        ]
