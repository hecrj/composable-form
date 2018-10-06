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
import List.Extra


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
    { value : values -> List subValues
    , update : List subValues -> values -> values
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
                        (\newSubValues values_ -> update (List.Extra.setAt index newSubValues listOfSubvalues) values_)
                        subValues
                        values

                filledSubForms =
                    List.indexedMap subformForIndex listOfSubvalues

                toForm index { fields } =
                    { fields = fields
                    , delete =
                        \_ ->
                            let
                                previousForms =
                                    List.take index listOfSubvalues

                                nextForms =
                                    List.drop (index + 1) listOfSubvalues
                            in
                            update (previousForms ++ nextForms) values
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
                    , add = \_ -> update (listOfSubvalues ++ [ default ]) values
                    , attributes = attributes
                    }
            , result = result
            , isEmpty = List.all .isEmpty filledSubForms
            }
        )
