module Form.Value
    exposing
        ( Value
        , blank
        , change
        , clean
        , dirty
        , newest
        , raw
        , withDefault
        )


type Value a
    = Blank Int
    | Clean Int a
    | Dirty Int a



-- CONSTRUCTORS


blank : Value a
blank =
    Blank 0


clean : a -> Value a
clean v =
    Clean 0 v


dirty : a -> Value a
dirty v =
    Dirty 0 v



-- GET


raw : Value a -> Maybe a
raw field =
    case field of
        Blank _ ->
            Nothing

        Clean _ v ->
            Just v

        Dirty _ v ->
            Just v


withDefault : a -> Value a -> Value a
withDefault default value =
    raw value
        |> Maybe.map (always value)
        |> Maybe.withDefault (clean default)



-- UPDATE


change : a -> Value a -> Value a
change v value =
    Dirty (version value + 1) v



-- CHOOSE


newest : (values -> Value a) -> values -> values -> Value a
newest getter values1 values2 =
    let
        value1 =
            getter values1

        value2 =
            getter values2
    in
    if version value1 >= version value2 then
        value1
    else
        value2



-- PRIVATE HELPERS


version : Value a -> Int
version value =
    case value of
        Blank version ->
            version

        Clean version _ ->
            version

        Dirty version _ ->
            version
