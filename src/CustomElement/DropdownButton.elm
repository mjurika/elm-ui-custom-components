module CustomElement.DropdownButton exposing
    ( dropdownButton
    , dropdownTitle
    , Item
    )

import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type alias Item =
    { name : String
    , action : String
    }

{-| Create a dropdownButton Html element.
-}
dropdownButton : List (Attribute msg) -> List (Html msg) -> Html msg
dropdownButton =
    Html.node "dropdown-button"


dropdownTitle : String -> Attribute msg
dropdownTitle title =
    property "dropdownTitle" <|
        Encode.string title


-- dropdownItems : List Item -> Attribute msg
-- dropdownItems items =
--     property "dropdownItems" <|
--         Encode.list items