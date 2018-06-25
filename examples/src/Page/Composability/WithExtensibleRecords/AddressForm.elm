module Page.Composability.WithExtensibleRecords.AddressForm
    exposing
        ( AddressForm
        , Values
        , blank
        , form
        )

import Data.Address as Address exposing (Address)
import Form exposing (Form)
import Form.Value as Value exposing (Value)


type alias AddressForm r =
    Form { r | address : Values } Address


type alias Values =
    { country : Value String
    , city : Value String
    , postalCode : Value String
    }


blank : Values
blank =
    { country = Value.blank
    , city = Value.blank
    , postalCode = Value.blank
    }


form : AddressForm r
form =
    let
        updateField f value values =
            let
                address =
                    f value values.address
            in
            { values | address = address }

        countryField =
            Form.textField
                { parser = Address.parseCountry
                , value = .address >> .country
                , update = updateField (\value values -> { values | country = value })
                , attributes =
                    { label = "Country"
                    , placeholder = "Type your country"
                    }
                }

        cityField =
            Form.textField
                { parser = Address.parseCity
                , value = .address >> .city
                , update = updateField (\value values -> { values | city = value })
                , attributes =
                    { label = "City"
                    , placeholder = "Type your city"
                    }
                }

        postalCodeField =
            Form.textField
                { parser = Address.parsePostalCode
                , value = .address >> .postalCode
                , update = updateField (\value values -> { values | postalCode = value })
                , attributes =
                    { label = "Postal Code"
                    , placeholder = "Type your postal code"
                    }
                }
    in
    Form.succeed Address
        |> Form.append countryField
        |> Form.append cityField
        |> Form.append postalCodeField
