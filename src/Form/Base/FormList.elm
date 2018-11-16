module Form.Base.FormList exposing
    ( FormList
    , form
    , Config, ElementConfig, Form
    )

{-| This module contains a reusable `FormList` type.

It is useful to build a variable list of forms based on a `List` of `values`.


# Definition

@docs FormList, Field


# Helpers

@docs form

-}

import Array exposing (Array)
import Form.Base as Base
import Form.Error exposing (Error)
import List.Extra


{-| Represents a variable list of forms.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

-}
type alias FormList values field =
    { forms : List (Form values field)
    , add : () -> values
    , attributes : Attributes
    }


{-| Represents an element in a list of forms.
-}
type alias Form values field =
    { fields : List ( field, Maybe Error )
    , delete : () -> values
    }


type alias Config values elementValues =
    { value : values -> List elementValues
    , update : List elementValues -> values -> values
    , default : elementValues
    , attributes : Attributes
    }


type alias Attributes =
    { add : String
    , delete : String
    }


type alias ElementConfig values elementValues =
    { index : Int
    , update : elementValues -> values -> values
    , values : values
    , elementValues : elementValues
    }


{-| Builds a [`Form`](Form-Base#Form) with a set of variable forms.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (FormList values field -> field)
    -> Config values elementValues
    -> (ElementConfig values elementValues -> Base.FilledForm output field)
    -> Base.Form values (List output) field
form tagger { value, update, default, attributes } buildElement =
    Base.custom
        (\values ->
            let
                listOfElementValues =
                    value values

                elementForIndex index elementValues =
                    buildElement
                        { update =
                            \newElementValues values_ ->
                                let
                                    newList =
                                        List.Extra.setAt index newElementValues listOfElementValues
                                in
                                update newList values_
                        , index = index
                        , values = values
                        , elementValues = elementValues
                        }

                filledElements =
                    List.indexedMap elementForIndex listOfElementValues

                toForm index { fields } =
                    { fields = fields
                    , delete =
                        \_ ->
                            let
                                previousForms =
                                    List.take index listOfElementValues

                                nextForms =
                                    List.drop (index + 1) listOfElementValues
                            in
                            update (previousForms ++ nextForms) values
                    }

                result =
                    List.foldr gatherResults (Ok []) filledElements

                gatherResults next current =
                    case next.result of
                        Ok output ->
                            Result.map ((::) output) current

                        Err ( head, errors ) ->
                            case current of
                                Ok _ ->
                                    Err ( head, errors )

                                Err ( currentHead, currentErrors ) ->
                                    Err ( head, errors ++ (currentHead :: currentErrors) )
            in
            { field =
                tagger
                    { forms = List.indexedMap toForm filledElements
                    , add = \_ -> update (listOfElementValues ++ [ default ]) values
                    , attributes = attributes
                    }
            , result = result
            , isEmpty = List.all .isEmpty filledElements
            }
        )
