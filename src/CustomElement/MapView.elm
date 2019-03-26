module CustomElement.MapView exposing
    ( baseMap
    , mapView
    , position
    )

import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- ALIAS


type alias Position =
    { latitude : Float
    , longitude : Float
    , accuracy : Float
    }



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


position : Maybe Position -> Attribute msg
position value =
    property "position" <|
        case value of
            Nothing ->
                Encode.string ""

            Just v ->
                Encode.object
                    [ ( "latitude", Encode.float v.latitude )
                    , ( "longitude", Encode.float v.longitude )
                    , ( "accuracy", Encode.float v.accuracy )
                    ]
