module Main exposing (main)

import Browser
import Browser.Dom as Dom
import CustomElement.DropdownButton as DropdownButton exposing (Item)
import CustomElement.GeoLocation as GeoLocation exposing (Position)
import CustomElement.MapView as MapView exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, field, string)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { title : String
    , items : List Item
    , baseMap : String
    , triggerPosition : Int
    , position : Maybe Position
    , inputText : String
    , status : Status
    }


type Status
    = Failure
    | Loading
    | Success (List SuggestResult)


type alias SuggestResult =
    { magicKey : String
    , text : String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { title = "Change basemaps"
      , items =
            [ { title = "Streets"
              , baseMap = "streets"
              }
            , { title = "Satellite"
              , baseMap = "satellite"
              }
            , { title = "Hybrid"
              , baseMap = "hybrid"
              }
            ]
      , baseMap = "satellite"
      , triggerPosition = 0
      , position = Nothing
      , inputText = "bra"
      , status = Loading
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Noop
    | OnClick String
    | TriggerPosition
    | Position Position
    | Search
    | GotResult (Result Http.Error (List SuggestResult))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        OnClick baseMap ->
            ( { model | baseMap = baseMap }
            , Cmd.none
            )

        TriggerPosition ->
            ( { model | triggerPosition = model.triggerPosition + 1 }
            , Cmd.none
            )

        Position value ->
            ( { model | position = Just value }
            , Cmd.none
            )

        Search ->
            ( { model | status = Loading }
            , suggest model.inputText
            )

        GotResult result ->
            case result of
                Ok url ->
                    ( { model | status = Success url }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | status = Failure }
                    , Cmd.none
                    )


positionToString : Maybe Position -> String
positionToString position =
    case position of
        Nothing ->
            "Ziadna pozicia"

        Just p ->
            "Lat: "
                ++ String.fromFloat p.latitude
                ++ ", Long: "
                ++ String.fromFloat p.longitude
                ++ ", Acc: "
                ++ String.fromFloat p.accuracy



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "row" ]
        [ div [ class "col s2" ]
            [ h4 []
                [ text "Elm custom elements"
                ]
            , DropdownButton.dropdownButton
                [ DropdownButton.dropdownTitle model.title
                , DropdownButton.dropdownItems model.items
                , DropdownButton.onClick OnClick
                ]
                []
            , div []
                [ span []
                    [ text "Selected basemap: " ]
                , strong []
                    [ text model.baseMap ]
                ]
            , br [] []
            , button
                [ class "btn"
                , onClick TriggerPosition
                ]
                [ text "Show my position" ]
            , GeoLocation.geoLocation
                [ GeoLocation.triggerPosition model.triggerPosition
                , GeoLocation.onPosition Position
                ]
                []
            , div []
                [ span []
                    [ text "position: " ]
                , strong []
                    [ text <| positionToString model.position ]
                ]
            , div []
                [ h2 [] [ text "Hladat" ]
                , viewResponse model.status
                ]
            , button [ onClick Search ] [ text "Hladat" ]
            ]
        , div [ class "col s10" ]
            [ MapView.mapView
                [ MapView.baseMap model.baseMap
                , MapView.position model.position
                ]
                []
            ]
        ]


viewResponse : Status -> Html Msg
viewResponse status =
    case status of
        Failure ->
            div []
                [ text "error" ]

        Loading ->
            text "Loading..."

        Success response ->
            div []
                [ text "podarilo sa" ]



-- HTTP


suggest : String -> Cmd Msg
suggest query =
    Http.get
        { url = "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/suggest?text=" ++ query ++ "&f=pjson&countryCode=SVK"
        , expect = Http.expectJson GotResult suggestListDecoder
        }



-- https://developers.arcgis.com/rest/geocode/api-reference/geocoding-suggest.htm


suggestListDecoder : Decoder (List SuggestResult)
suggestListDecoder =
    field "suggestions" (Decode.list suggestDecoder)


suggestDecoder : Decoder SuggestResult
suggestDecoder =
    Decode.map2 SuggestResult
        (Decode.field "magicKey" Decode.string)
        (Decode.field "text" Decode.string)



-- suggestDecoder : Decoder String
-- suggestDecoder =
--     field "data" (field "url" string)
