module Form.Base.VariableForm exposing
    ( VariableForm
    , form
    , Config, Form
    )

{-| This module contains a reusable `VariableForm` type.

It is useful to build forms that have variable fields based on a
`List` of `values`.


# Definition

@docs VariableForm, Field


# Helpers

@docs form

-}

import Array exposing (Array)
import Form.Base as Base
import Form.Error exposing (Error)


{-| Represents a set of variable forms.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

-}
type alias VariableForm values field =
    { forms : List (Form values field)
    , add : () -> values
    , attributes : Attributes
    }


{-| Represents a variable field.
-}
type alias Form values field =
    { fields : List ( field, Maybe Error )
    , delete : () -> values
    }


type alias Config values subValues =
    { value : values -> Array subValues
    , update : Array subValues -> values -> values
    , default : subValues
    , attributes : Attributes
    }


type alias Attributes =
    { add : String
    , delete : String
    }


{-| Builds a [`Form`](Form-Base#Form) with a set of variable forms.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (VariableForm values field -> field)
    -> Config values subValues
    -> ((subValues -> values -> values) -> subValues -> values -> Base.FilledForm output field)
    -> Base.Form values (List output) field
form tagger { value, update, default, attributes } buildSubform =
    Base.custom
        (\values ->
            let
                listOfSubvalues =
                    value values

                subformForIndex index subValues =
                    buildSubform
                        (\newSubValues values_ -> update (Array.set index newSubValues listOfSubvalues) values_)
                        subValues
                        values

                filledSubForms =
                    Array.indexedMap subformForIndex listOfSubvalues
                        |> Array.toList

                toForm index { fields } =
                    { fields = fields
                    , delete =
                        \_ ->
                            let
                                newList =
                                    Array.slice (index + 1) (Array.length listOfSubvalues) listOfSubvalues
                                        |> Array.append (Array.slice 0 index listOfSubvalues)
                            in
                            update newList values
                    }

                result =
                    List.foldr gatherResults (Ok []) filledSubForms

                gatherResults next current =
                    case next.result of
                        Ok output ->
                            Result.map ((::) output) current

                        Err ( head, errors ) ->
                            Result.mapError
                                (\( currentHead, currentErrors ) ->
                                    ( head, errors ++ (currentHead :: currentErrors) )
                                )
                                current
            in
            { field =
                tagger
                    { forms = List.indexedMap toForm filledSubForms
                    , add = \_ -> update (Array.push default listOfSubvalues) values
                    , attributes = attributes
                    }
            , result = result
            , isEmpty = List.all .isEmpty filledSubForms
            }
        )
