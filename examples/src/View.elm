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
        snippetToHtml { filename, path, code } =
            [ Html.i [ Attributes.class "far fa-file-code" ] []
            , Html.text " "
            , Html.a [ Attributes.href (examplesUrl ++ path) ] [ Html.text filename ]
            , Html.text "\n\n"
            , Html.text code
            , Html.text "\n"
            ]
    in
    List.map snippetToHtml
        >> List.intersperse [ Html.text "\n\n" ]
        >> List.concatMap identity
        >> Html.pre []
