module CustomElement.AutoComplete exposing
    ( SuggestResult
    , autoComplete
    , label
    , data
    , value
    , onInput
    )

import Html exposing (Attribute, Html)
import Html.Attributes exposing (property)
import Html.Events exposing (on)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- ALIAS


type alias SuggestResult =
    { magicKey : String
    , text : String
    }


-- HTML node


{-| Create a autoComplete Html element.
-}
autoComplete : List (Attribute msg) -> List (Html msg) -> Html msg
autoComplete =
    Html.node "auto-complete"



-- HTML attributes


label : String -> Attribute msg
label lab =
    property "label" <|
        Encode.string lab


data : List SuggestResult -> Attribute msg
data dat =
    property "data" <|
        suggestListEncoder dat


value : String -> Attribute msg
value val =
    property "value" <|
        Encode.string val



-- Event handlers


onInput : (String -> msg) -> Attribute msg
onInput tagger =
    on "onInput" <|
        Decode.map tagger <|
            Decode.at [ "target", "value" ]
                Decode.string



-- Encoders


suggestListEncoder : List SuggestResult -> Encode.Value
suggestListEncoder results =
    Encode.list suggestEncode results


suggestEncode : SuggestResult -> Encode.Value
suggestEncode result =
    Encode.object
            [ ( "magicKey", Encode.string result.magicKey )
            , ( "text", Encode.string result.text )
            ]