module Form.Field exposing (Field, mapValues)

{-| This module contains a type that represents a generic form field.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

@docs Field, mapValues

-}


{-| Represents a form field.

It contains:

  - the current `value` of the field
  - an `update` function that takes a new **field** value and returns updated
    **form** values
  - the `attributes` of the field

These record fields are normally used in view code to set up the `value` and `onInput`
attributes. For example, you could render a `TextField` like this:

    view : (values -> msg) -> Form values output -> values -> Html output
    view onChange form values =
        let
            { fields, result } =
                Form.fill form values

            fieldsHtml =
                List.map (viewField onChange) fields

            -- ...
        in
        Html.form
            [-- ...
            ]
            [ Html.div [] fieldsHtml
            , submitButton
            ]

    viewField : (values -> msg) -> ( Form.Field values, Maybe Error ) -> Html msg
    viewField onChange ( field, maybeError ) =
        case field of
            Form.Text TextField.Raw { value, update, attributes } ->
                Html.input
                    [ Attributes.type_ "text"
                    , Attributes.value value
                    , Attributes.onInput (update >> onChange)
                    , Attributes.placeholder attributes.placeholder
                    ]
                    []

            _ ->
                -- ...

-}
type alias Field attributes value values =
    { value : value
    , update : value -> values
    , attributes : attributes
    }


{-| Transform the `values` of a `Field`.

It can be useful to build your own [`Form.mapValues`](Form#mapValues) function.

-}
mapValues : (a -> b) -> Field attributes value a -> Field attributes value b
mapValues fn { value, update, attributes } =
    { value = value
    , update = update >> fn
    , attributes = attributes
    }
