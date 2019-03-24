module CustomElement.DropdownButton exposing
    ( Item
    , dropdownButton
    , dropdownItems
    , dropdownTitle
    , onClick
    )

import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- ALIAS


type alias Item =
    { title : String
    , action : String
    }



-- HTML node


{-| Create a dropdownButton Html element.
-}
dropdownButton : List (Attribute msg) -> List (Html msg) -> Html msg
dropdownButton =
    Html.node "dropdown-button"



-- HTML attributes


dropdownTitle : String -> Attribute msg
dropdownTitle title =
    property "dropdownTitle" <|
        Encode.string title


dropdownItems : List Item -> Attribute msg
dropdownItems items =
    property "dropdownItems" <|
        encodeItemList items


action : String -> Attribute msg
action value =
    property "action" <|
        Encode.string value



-- Event handlers


onClick : (String -> msg) -> Attribute msg
onClick tagger =
    on "btnClicked" <|
        Decode.map tagger <|
            Decode.at [ "target", "action" ]
                Decode.string



-- Encoders


encodeItemList : List Item -> Encode.Value
encodeItemList items =
    Encode.list encodeItem items


encodeItem : Item -> Encode.Value
encodeItem item =
    Encode.object
        [ ( "title", Encode.string item.title )
        , ( "action", Encode.string item.action )
        ]



-- dropdownItems : List Item -> Attribute msg
-- dropdownItems items =
--     property "dropdownItems" <|
--         Encode.string """[{"title":"one","action":"btn-one-clicked"},{"title":"two","action":"btn-two-clicked"}]"""
-- encodeAction : String -> Encode.Value
-- encodeAction action =
--     Encode.string action
-- encodeTitle : String -> Encode.Value
-- encodeTitle title =
--     Encode.string title
