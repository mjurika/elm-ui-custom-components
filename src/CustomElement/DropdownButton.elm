module CustomElement.DropdownButton exposing
    ( dropdownButton
    , dropdownTitle
    )

import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Json.Decode as JD exposing (Decoder)
import Json.Encode as JE exposing (Value)


{-| Create a dropdownButton Html element.
-}
dropdownButton : List (Attribute msg) -> List (Html msg) -> Html msg
dropdownButton =
    Html.node "dropdown-button"


{-| This is how you set the contents of the code editor.
-}
dropdownTitle : String -> Attribute msg
dropdownTitle title =
    property "dropdownTitle" <|
        JE.string title
