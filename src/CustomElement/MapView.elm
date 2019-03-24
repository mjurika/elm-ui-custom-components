module CustomElement.MapView exposing
    ( baseMap
    , mapView
    )

import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- ALIAS
-- HTML node


{-| Create a mapView Html element.
-}
mapView : List (Attribute msg) -> List (Html msg) -> Html msg
mapView =
    Html.node "map-view"



-- HTML attributes


baseMap : String -> Attribute msg
baseMap mapId =
    property "baseMap" <|
        Encode.string mapId
