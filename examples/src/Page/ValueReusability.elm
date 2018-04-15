module Page.ValueReusability exposing (Model, Msg, init, update, view)

import Data.Post as Post
import Data.Question as Question
import Form exposing (Form)
import Form.Value as Value exposing (Value)
import Form.View
import Html exposing (Html)


type alias Model =
    Form.View.Model Values


type alias Values =
    { title : Value String
    , body : Value String
    }


type Msg
    = FormChanged (Form.View.Model Values)
    | NewPost Post.Body
    | NewQuestion Question.Title (Maybe Question.Body)


init : Model
init =
    { title = Value.blank
    , body = Value.blank
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


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h1 [] [ Html.text "Value reusability" ]
        , Html.p [] [ Html.text "The value for the body fields is reused in both forms with a single source of truth" ]
        , Html.h2 [] [ Html.text "New Post" ]
        , Form.View.basic
            { onChange = FormChanged
            , action = "New Post"
            , loadingMessage = "Loading..."
            , validation = Form.View.ValidateOnSubmit
            }
            postForm
            model
        , Html.h2 [] [ Html.text "New Question" ]
        , Form.View.basic
            { onChange = FormChanged
            , action = "New Question"
            , loadingMessage = "Loading..."
            , validation = Form.View.ValidateOnSubmit
            }
            questionForm
            model
        ]


postForm : Form Values Msg
postForm =
    let
        bodyField =
            Form.textAreaField
                { parser = Post.parseBody
                , value = .body
                , update = \value values -> { values | body = value }
                , attributes =
                    { label = "Post body"
                    , placeholder = "Type your post here..."
                    }
                }
    in
    Form.empty NewPost
        |> Form.append bodyField


questionForm : Form Values Msg
questionForm =
    let
        titleField =
            Form.textField
                { parser = Question.parseTitle
                , value = .title
                , update = \value values -> { values | title = value }
                , attributes =
                    { label = "Question title"
                    , placeholder = "Type your question here..."
                    }
                }

        bodyField =
            Form.textAreaField
                { parser = Question.parseBody
                , value = .body
                , update = \value values -> { values | body = value }
                , attributes =
                    { label = "Question body"
                    , placeholder = "Describe your question here... (optional)"
                    }
                }
    in
    Form.empty NewQuestion
        |> Form.append titleField
        |> Form.append (Form.optional bodyField)
