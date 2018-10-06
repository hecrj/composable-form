module View exposing (code, repositoryUrl)

import Html exposing (Html)
import Html.Attributes as Attributes


type alias CodeSnippet =
    { filename : String
    , path : String
    , code : String
    }


repositoryUrl : String
repositoryUrl =
    "https://github.com/hecrj/composable-form"


examplesUrl : String
examplesUrl =
    repositoryUrl ++ "/blob/master/examples/src/Page/"


code : List CodeSnippet -> Html msg
code =
    let
        snippetToHtml snippet =
            [ Html.i [ Attributes.class "far fa-file-code" ] []
            , Html.text " "
            , Html.a [ Attributes.href (examplesUrl ++ snippet.path) ] [ Html.text snippet.filename ]
            , Html.text "\n\n"
            , Html.text snippet.code
            , Html.text "\n"
            ]
    in
    List.map snippetToHtml
        >> List.intersperse [ Html.text "\n\n" ]
        >> List.concatMap identity
        >> Html.pre []
