module Form.Base.FormList exposing
    ( FormList, Form, Attributes
    , Config, ElementState, form
    )

{-| This module contains a reusable `FormList` type.

It is useful to build a variable list of forms based on a `List` of `values`.


# Definition

@docs FormList, Form, Attributes


# Helpers

@docs Config, ElementState, form

-}

import Array exposing (Array)
import Form.Base as Base
import Form.Error exposing (Error)
import List.Extra


{-| Represents a list of forms.

**Note:** You should not need to care about this unless you are creating your own
custom fields or writing custom view code.

It contains a list of forms, a lazy `add` action to add a new item to the list,
and some [Attributes](Form.Base.FormList#Attributes).

-}
type alias FormList values field =
    { forms : List (Form values field)
    , add : () -> values
    , attributes : Attributes
    }


{-| Represents an element in a list of forms.

It contains the fields of the form and a lazy `delete` action to remove itself
from the list.

-}
type alias Form values field =
    { fields : List (Base.FilledField field)
    , delete : () -> values
    }


{-| The attributes of a `FormList`.

`add` and `delete` are optional labels for the add and delete buttons,
respectively. Providing `Nothing` hides the button.

-}
type alias Attributes =
    { label : String
    , add : Maybe String
    , delete : Maybe String
    }


{-| The configuration of a `FormList`.

  - `value` describes how to obtain a `List` with the values of the forms
    in the list.
  - `update` describes how to replace a new `List` of element values in the
    `values` of the form.
  - `default` defines the values that a new element will have when added to the list.

-}
type alias Config values elementValues =
    { value : values -> List elementValues
    , update : List elementValues -> values -> values
    , default : elementValues
    , attributes : Attributes
    }


{-| Describes the state of a particular element in a form list.

  - `index` is the position of the element in the list.
  - `update` defines how to update the current element.
  - `values` contains the current values of the form.
  - `elementValues` contains the current values of the element in the list.

-}
type alias ElementState values elementValues =
    { index : Int
    , update : elementValues -> values -> values
    , values : values
    , elementValues : elementValues
    }


{-| Builds a [`Form`](Form-Base#Form) with a variable list of forms.

**Note:** You should not need to care about this unless you are creating your own
custom fields.

-}
form :
    (FormList values field -> field)
    -> Config values elementValues
    -> (ElementState values elementValues -> Base.FilledForm output field)
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
            { state =
                tagger
                    { forms = List.indexedMap toForm filledElements
                    , add = \_ -> update (listOfElementValues ++ [ default ]) values
                    , attributes = attributes
                    }
            , result = result
            , isEmpty = List.all .isEmpty filledElements
            }
        )
