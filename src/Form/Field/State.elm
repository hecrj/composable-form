module Form.Field.State exposing (State)

{-| This module contains a type that represents the [`State`](#State)
of a form field.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing your own form renderer.

@docs State

-}

import Form.Value exposing (Value)


{-| Represents the state of a form field.

It contains:

  - the current `value` of the field
  - an `update` function that takes a new **field** value and returns updated
    **form** values

These attributes are normally used in renderers to set up the `value` and `onInput`
attributes. For example, you could render a `TextField` like this:

    view : (values -> msg) -> Form values output -> values -> Html output
    view onChange form values =
        let
            fields =
                List.map (viewField onChange) (Form.fields form values)

            -- ...
        in
        Html.form
            [-- ...
            ]
            [ Html.div [] fields
            , submitButton
            ]

    viewField : (values -> msg) -> ( Form.Field values, Maybe Error ) -> Html msg
    viewField onChange ( field, maybeError ) =
        case field of
            Form.Text TextField.Raw { attributes, state } ->
                Html.input
                    [ Attributes.type_ "text"
                    , Attributes.value
                        (state.value
                            |> Value.raw
                            |> Maybe.withDefault ""
                        )
                    , Attributes.onInput (state.update >> onChange)
                    ]
                    []

            _ ->
                -- ...

-}
type alias State value values =
    { value : Value value
    , update : value -> values
    }
