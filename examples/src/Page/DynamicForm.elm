module Page.DynamicForm exposing (Model, Msg, init, update, view)

import Data.Post as Post
import Data.Question as Question
import Form exposing (Form)
import Form.View
import Html exposing (Html)
import View


type alias Model =
    Form.View.Model Values


type alias Values =
    { publicationType : String
    , title : String
    , body : String
    }


type Msg
    = FormChanged (Form.View.Model Values)
    | NewPost Post.Body
    | NewQuestion Question.Title (Maybe Question.Body)


init : Model
init =
    { publicationType = ""
    , title = ""
    , body = ""
    }
        |> Form.View.idle


update : Msg -> Model -> Model
update msg model =
    case msg of
        FormChanged newForm ->
            newForm

        NewPost body ->
            { model | state = Form.View.Loading }

        NewQuestion title maybeBody ->
            { model | state = Form.View.Loading }


view : View.FormView -> Model -> Html Msg
view formView model =
    Html.div []
        [ Html.h1 [] [ Html.text "Dynamic form" ]
        , Html.p [] [ Html.text "A form that changes based on a field value." ]
        , code
        , View.form formView
            { onChange = FormChanged
            , action = "New Publication"
            , loading = "Loading..."
            , validation = Form.View.ValidateOnSubmit
            }
            publicationForm
            model
        ]


type PublicationType
    = Post
    | Question


publicationForm : Form Values Msg
publicationForm =
    let
        publicationTypeField =
            Form.selectField
                { parser =
                    \value ->
                        case value of
                            "post" ->
                                Ok Post

                            "question" ->
                                Ok Question

                            _ ->
                                Err "Invalid publication type"
                , value = .publicationType
                , update = \value values -> { values | publicationType = value }
                , error = always Nothing
                , attributes =
                    { label = "Type of publication"
                    , placeholder = "Choose a type"
                    , options = [ ( "post", "Post" ), ( "question", "Question" ) ]
                    }
                }
    in
    publicationTypeField
        |> Form.andThen
            (\publicationType ->
                case publicationType of
                    Post ->
                        postForm

                    Question ->
                        questionForm
            )


postForm : Form Values Msg
postForm =
    let
        bodyField =
            Form.textareaField
                { parser = Post.parseBody
                , value = .body
                , update = \value values -> { values | body = value }
                , error = always Nothing
                , attributes =
                    { label = "Body"
                    , placeholder = "Type your post here..."
                    }
                }
    in
    Form.succeed NewPost
        |> Form.append bodyField
        |> Form.section "Post"


questionForm : Form Values Msg
questionForm =
    let
        titleField =
            Form.textField
                { parser = Question.parseTitle
                , value = .title
                , update = \value values -> { values | title = value }
                , error = always Nothing
                , attributes =
                    { label = "Title"
                    , placeholder = "Type your question here..."
                    }
                }

        bodyField =
            Form.textareaField
                { parser = Question.parseBody
                , value = .body
                , update = \value values -> { values | body = value }
                , error = always Nothing
                , attributes =
                    { label = "Body"
                    , placeholder = "Describe your question here... (optional)"
                    }
                }
    in
    Form.succeed NewQuestion
        |> Form.append titleField
        |> Form.append (Form.optional bodyField)
        |> Form.section "Question"


code : Html msg
code =
    View.code
        [ { filename = "DynamicForm.elm"
          , path = "DynamicForm.elm"
          , code = """publicationTypeField
    |> Form.andThen
        (\\publicationType ->
            case publicationType of
                Post ->
                    postForm

                Question ->
                    questionForm
        )"""
          }
        ]
