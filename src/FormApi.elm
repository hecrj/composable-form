module FormApi exposing (..)

-- Encapsulation

import DynamicForm.Form as Form exposing (Form)
import DynamicForm.View
import Form.Error
import Html exposing (Html)
import Multiselect


type alias Model values output =
    { formModel : DynamicForm.View.Model values
    , form : Form values output
    , action : String
    , loading : String
    }


init :
    { form : Form values output
    , action : String
    , loading : String
    , initialValues : values
    }
    -> Model values output
init { form, action, loading, initialValues } =
    { formModel =
        initialValues
            |> DynamicForm.View.idle
    , form = form
    , action = action
    , loading = loading
    }


type Reply output
    = Succeeded output


type Msg values output
    = FormChanged (DynamicForm.View.Model values)
    | Succeed output
    | MultiselectMsg Multiselect.Msg Multiselect.Model (Multiselect.Model -> values)


update :
    Msg values output
    -> Model values output
    -> ( Model values output, Cmd (Msg values output), List (Reply output) )
update msg model =
    case msg of
        FormChanged newModel ->
            --    let
            --        result =
            --            fill model.form   newModel.values
            --                |> .result
            --                |> Result.mapError (\ (error, errors) -> errorToString error :: List.map errorToString errors)
            --    in
            ( { model
                | formModel = newModel
              }
            , Cmd.none
            , []
            )

        MultiselectMsg subMsg value subUpdate ->
            let
                formModel =
                    Debug.log "multiselect old model"
                        model.formModel

                ( subModel, subCmd, outMsg ) =
                    Multiselect.update subMsg value
            in
            Debug.log "multiselect new model"
                ( { model
                    | formModel =
                        { formModel
                            | values =
                                subUpdate subModel
                        }
                  }
                , Cmd.map (\a -> MultiselectMsg a value subUpdate) subCmd
                , []
                )

        Succeed output ->
            ( model
            , Cmd.none
            , [ Succeeded output ]
            )


view : Model values output -> Html (Msg values output)
view model =
    let
        form_ =
            Form.map Succeed model.form
    in
    DynamicForm.View.asHtml
        { onChange = FormChanged
        , action = model.action
        , loading = model.loading
        , validation = DynamicForm.View.ValidateOnSubmit
        , multiselectMsg = MultiselectMsg
        }
        form_
        model.formModel


errorToString : Form.Error.Error -> String
errorToString error =
    case error of
        Form.Error.RequiredFieldIsEmpty ->
            "this field is required"

        Form.Error.ValidationFailed errorDescription ->
            errorDescription

        Form.Error.External string ->
            string
