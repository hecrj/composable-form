module Page.Composability.Simple.AddressForm exposing (Values, blank, form)

import Data.Address as Address exposing (Address)
import Form exposing (Form)


type alias Values =
    { country : String
    , city : String
    , postalCode : String
    }


blank : Values
blank =
    { country = ""
    , city = ""
    , postalCode = ""
    }


form : Form Values Address
form =
    let
        countryField =
            Form.textField
                { parser = Address.parseCountry
                , value = .country
                , update = \value values -> { values | country = value }
                , error = always Nothing
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
                , error = always Nothing
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
                , error = always Nothing
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
