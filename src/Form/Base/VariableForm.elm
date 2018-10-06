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


type alias Config values childValues =
    { value : values -> List childValues
    , update : List childValues -> values -> values
    , default : childValues
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
    -> Config values childValues
    -> ((childValues -> values -> values) -> childValues -> values -> Base.FilledForm output field)
    -> Base.Form values (List output) field
form tagger { value, update, default, attributes } buildChildForm =
    Base.custom
        (\values ->
            let
                listOfChildValues =
                    value values

                childFormForIndex index childValues =
                    buildChildForm
                        (\newChildValues values_ ->
                            let
                                newList =
                                    List.Extra.setAt index newChildValues listOfChildValues
                            in
                            update newList values_
                        )
                        childValues
                        values

                filledChildForms =
                    List.indexedMap childFormForIndex listOfChildValues

                toForm index { fields } =
                    { fields = fields
                    , delete =
                        \_ ->
                            let
                                previousForms =
                                    List.take index listOfChildValues

                                nextForms =
                                    List.drop (index + 1) listOfChildValues
                            in
                            update (previousForms ++ nextForms) values
                    }

                result =
                    List.foldr gatherResults (Ok []) filledChildForms

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
                    { forms = List.indexedMap toForm filledChildForms
                    , add = \_ -> update (listOfChildValues ++ [ default ]) values
                    , attributes = attributes
                    }
            , result = result
            , isEmpty = List.all .isEmpty filledChildForms
            }
        )
