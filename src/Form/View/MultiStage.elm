module Form.View.MultiStage
    exposing
        ( Build
        , Form
        , Model
        , State(..)
        , add
        , build
        , end
        , idle
        , view
        )

import Form
import Form.Error exposing (Error)
import Form.View
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events


type Form values output
    = Form (List (Stage values)) (Form.Form values output)


type Stage values
    = Stage (values -> List ( Form.Field values, Maybe Error )) (values -> Maybe (Html Never))



-- Build


type Build values output
    = Build (Form values output)


build : output -> Build values output
build output =
    Form [] (Form.empty output)
        |> Build


add : Form.Form values a -> (a -> Html Never) -> Build values (a -> b) -> Build values b
add form toHtml (Build (Form stages currentForm)) =
    let
        viewStage =
            Form.result form >> Result.map toHtml >> Result.toMaybe

        newStage =
            Stage (Form.fields form) viewStage
    in
    Form (stages ++ [ newStage ]) (currentForm |> Form.append form)
        |> Build


end : Form.Form values a -> Build values (a -> b) -> Form values b
end form build_ =
    case add form (always (Html.text "")) build_ of
        Build multiStageForm ->
            multiStageForm



-- View


type alias Model values =
    { values : values
    , state : State
    , stage : Int
    , showErrors : Bool
    }


type State
    = Idle
    | Loading
    | Error String


idle : values -> Model values
idle values =
    { values = values
    , state = Idle
    , stage = 0
    , showErrors = False
    }


type alias ViewConfig values msg =
    { onChange : Model values -> msg
    , action : String
    , loading : String
    , next : String
    , back : String
    }


view : ViewConfig values output -> Form values output -> Model values -> Html output
view { onChange, action, loading, next, back } (Form stages form) model =
    let
        isLastStage =
            model.stage + 1 == List.length stages

        currentStage =
            stages |> List.drop model.stage |> List.head

        maybeShowErrors =
            if model.showErrors then
                Nothing
            else
                Just (onChange { model | showErrors = True })

        onSubmitMsg =
            if isLastStage then
                case Form.result form model.values of
                    Ok msg ->
                        if model.state == Loading then
                            Nothing
                        else
                            Just msg

                    Err _ ->
                        maybeShowErrors
            else
                case currentStage of
                    Just (Stage _ stageView) ->
                        case stageView model.values of
                            Just _ ->
                                Just (onChange { model | stage = model.stage + 1, showErrors = False })

                            Nothing ->
                                maybeShowErrors

                    Nothing ->
                        Nothing

        onSubmit =
            onSubmitMsg
                |> Maybe.map (Events.onSubmit >> List.singleton)
                |> Maybe.withDefault []

        filledStages =
            List.keep model.stage stages
                |> List.map
                    (\(Stage _ stageView) ->
                        stageView model.values
                            |> Maybe.map (Html.map (always (onChange model)))
                            |> Maybe.withDefault (Html.text "error")
                    )

        currentStageFields =
            case stages |> List.drop model.stage |> List.head of
                Just (Stage builder _) ->
                    builder model.values
                        |> List.map
                            (Form.View.field
                                { onChange = \values -> onChange { model | values = values }
                                , onBlur = Nothing
                                , disabled = model.state == Loading
                                , showError = always model.showErrors
                                }
                            )

                Nothing ->
                    [ Html.text "" ]

        controls =
            [ case model.state of
                Error error ->
                    Form.View.errorMessage (Just error)

                _ ->
                    Html.text ""
            , Html.div [ Attributes.class "elm-form-multistage-controls" ]
                [ if model.stage == 0 || model.state == Loading then
                    Html.div [] []
                  else
                    Html.a
                        [ Attributes.class "elm-form-multistage-back"
                        , Events.onClick (onChange { model | stage = model.stage - 1 })
                        ]
                        [ Html.text back ]
                , Html.button
                    [ Attributes.type_ "submit"
                    , Attributes.disabled (onSubmitMsg == Nothing)
                    ]
                    [ if model.state == Loading then
                        Html.text loading
                      else if isLastStage then
                        Html.text action
                      else
                        Html.text next
                    ]
                ]
            ]
    in
    Html.form (Attributes.class "elm-form-multistage" :: onSubmit)
        (List.concat
            [ filledStages
            , currentStageFields
            , controls
            ]
        )
