module Page.ReusingValues exposing (Model, Msg, init, update, view)

import Data.Post as Post
import Data.Question as Question
import Form exposing (Form)
import Form.Value as Value exposing (Value)
import Form.View
import Html exposing (Html)
import Html.Attributes as Attributes
import Html.Events as Events


type alias Model =
    { contentType : ContentType
    , form : Form.View.Model Values
    }


type ContentType
    = Post
    | Question


type alias Values =
    { title : Value String
    , body : Value String
    }


type Msg
    = ChangeContentType ContentType
    | FormChanged (Form.View.Model Values)
    | NewPost Post.Body
    | NewQuestion Question.Title (Maybe Question.Body)


init : Model
init =
    { contentType = Post
    , form =
        { title = Value.blank
        , body = Value.blank
        }
            |> Form.View.idle
    }


update : Msg -> Model -> Model
update msg model =
    let
        form =
            model.form
    in
    case msg of
        ChangeContentType contentType ->
            { model | contentType = contentType }

        FormChanged newForm ->
            { model | form = newForm }

        NewPost body ->
            { model | form = { form | state = Form.View.Loading } }

        NewQuestion title maybeBody ->
            { model | form = { form | state = Form.View.Loading } }


view : Model -> Html Msg
view model =
    let
        contentTypeSwitch =
            Html.div [ Attributes.class "tabs" ]
                [ Html.button
                    [ Events.onClick (ChangeContentType Post) ]
                    [ Html.text "New Post" ]
                , Html.button
                    [ Events.onClick (ChangeContentType Question) ]
                    [ Html.text "New Question" ]
                ]
    in
    Html.div []
        [ Html.h1 [] [ Html.text "Reusing values" ]
        , if model.form.state == Form.View.Loading then
            Html.text ""
          else
            contentTypeSwitch
        , case model.contentType of
            Post ->
                Form.View.basic
                    { onChange = FormChanged
                    , action = "New Post"
                    , loadingMessage = "Publishing post..."
                    }
                    postForm
                    model.form

            Question ->
                Form.View.basic
                    { onChange = FormChanged
                    , action = "New Question"
                    , loadingMessage = "Publishing question..."
                    }
                    questionForm
                    model.form
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
