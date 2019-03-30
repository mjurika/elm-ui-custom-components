module CustomElement.MapView exposing
    ( Extent
    , Geometry
    , Location
    , baseMap
    , geometry
    , mapView
    , measurement
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


type alias Geometry =
    { location : Location
    , extent : Extent
    }


type alias Location =
    { x : Float
    , y : Float
    }


type alias Extent =
    { xmin : Float
    , ymin : Float
    , xmax : Float
    , ymax : Float
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


measurement : String -> Attribute msg
measurement measurementType =
    property "measurement" <|
        Encode.string measurementType


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


geometry : List Geometry -> Attribute msg
geometry geom =
    property "geometry" <|
        geometryListEncoder geom



-- Encoders


geometryListEncoder : List Geometry -> Encode.Value
geometryListEncoder geometries =
    Encode.list geometryEncoder geometries


geometryEncoder : Geometry -> Encode.Value
geometryEncoder geom =
    Encode.object
        [ ( "location", locationEncoder geom.location )
        , ( "extent", extentEncoder geom.extent )
        ]


locationEncoder : Location -> Encode.Value
locationEncoder loc =
    Encode.object
        [ ( "x", Encode.float loc.x )
        , ( "y", Encode.float loc.y )
        ]


extentEncoder : Extent -> Encode.Value
extentEncoder ext =
    Encode.object
        [ ( "xmin", Encode.float ext.xmin )
        , ( "ymin", Encode.float ext.ymin )
        , ( "xmax", Encode.float ext.xmax )
        , ( "ymax", Encode.float ext.ymax )
        ]
