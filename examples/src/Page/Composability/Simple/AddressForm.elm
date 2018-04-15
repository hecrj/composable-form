module Page.Composability.Simple.AddressForm exposing (AddressForm, Values, blank, form)

import Data.Address as Address exposing (Address)
import Form exposing (Form)
import Form.Value as Value exposing (Value)


type alias AddressForm =
    Form Values Address


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


form : AddressForm
form =
    let
        countryField =
            Form.textField
                { parser = Address.parseCountry
                , value = .country
                , update = \value values -> { values | country = value }
                , attributes =
                    { label = "Country"
                    , placeholder = "Type your country"
                    }
                }

        cityField =
            Form.textField
                { parser = Address.parseCity
                , value = .city
                , update = \value values -> { values | city = value }
                , attributes =
                    { label = "City"
                    , placeholder = "Type your city"
                    }
                }

        postalCodeField =
            Form.textField
                { parser = Address.parsePostalCode
                , value = .postalCode
                , update = \value values -> { values | postalCode = value }
                , attributes =
                    { label = "Postal Code"
                    , placeholder = "Type your postal code"
                    }
                }
    in
    Form.empty Address
        |> Form.append countryField
        |> Form.append cityField
        |> Form.append postalCodeField
