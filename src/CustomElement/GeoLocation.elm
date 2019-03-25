module CustomElement.GeoLocation exposing
    ( Position
    , geoLocation
    , onPosition
    , triggerPosition
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
    }



-- HTML node


{-| Create a geoLocation Html element.
-}
geoLocation : List (Attribute msg) -> List (Html msg) -> Html msg
geoLocation =
    Html.node "geo-location"



-- HTML attributes


triggerPosition : Int -> Attribute msg
triggerPosition value =
    property "triggerPosition" <|
        Encode.int value


onPosition : (Position -> msg) -> Attribute msg
onPosition tagger =
    on "position" <|
        Decode.map tagger <|
            Decode.at [ "target", "position" ] positionDecoder



-- Decoders


positionDecoder : Decoder Position
positionDecoder =
    Decode.value
        |> Decode.andThen positionDecoderDebug


positionDecoderDebug : Value -> Decoder Position
positionDecoderDebug value =
    Decode.map2 Position
        (Decode.field "latitude" Decode.float)
        (Decode.field "longitude" Decode.float)
