module Main exposing (main)

import Browser
import Browser.Dom as Dom
import CustomElement.AutoComplete as AutoComplete exposing (..)
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
    , autoCompleteLabel : String
    , value : String
    , geometryStatus : GeometryStatus
    }


type Status
    = Failure
    | Loading
    | Success (List SuggestResult)


type GeometryStatus
    = FailGeom
    | LoadingGeom
    | SuccessGeom (List Geometry)


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
      , autoCompleteLabel = "Search in map"
      , value = ""
      , geometryStatus = LoadingGeom
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
    | OnInput String
    | OnAutocomplete String
    | GotGeometry (Result Http.Error (List Geometry))


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

        OnInput val ->
            ( { model | status = Loading }
            , suggest val
            )

        OnAutocomplete magicKey ->
            ( { model | geometryStatus = LoadingGeom }
            , getGeometry magicKey
            )

        GotGeometry result ->
            case result of
                Ok url ->
                    ( { model | geometryStatus = SuccessGeom url }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | geometryStatus = FailGeom }
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
            , AutoComplete.autoComplete
                [ AutoComplete.label model.autoCompleteLabel
                , AutoComplete.value model.value
                , AutoComplete.onInput OnInput
                , AutoComplete.onAutocomplete OnAutocomplete
                , case model.status of
                    Failure ->
                        class "fail"

                    Loading ->
                        class "loading"

                    Success response ->
                        AutoComplete.data response
                ]
                []
            ]
        , div [ class "col s10" ]
            [ MapView.mapView
                [ MapView.baseMap model.baseMap
                , MapView.position model.position
                , case model.geometryStatus of
                    FailGeom ->
                        id "error"

                    LoadingGeom ->
                        id "loading"

                    SuccessGeom geom ->
                        MapView.geometry geom
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
        { url = "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/suggest?text=" ++ query ++ "&f=json&countryCode=SVK"
        , expect = Http.expectJson GotResult suggestListDecoder
        }


getGeometry : String -> Cmd Msg
getGeometry key =
    Http.get
        { url = "http://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/findAddressCandidates?f=json&magicKey=" ++ key
        , expect = Http.expectJson GotGeometry geometryListDecoder
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


geometryListDecoder : Decoder (List Geometry)
geometryListDecoder =
    field "candidates" (Decode.list geometryDecoder)


geometryDecoder : Decoder Geometry
geometryDecoder =
    Decode.map2 Geometry
        (Decode.field "location" locationDecoder)
        (Decode.field "extent" extentDecoder)


locationDecoder : Decoder Location
locationDecoder =
    Decode.map2 Location
        (Decode.field "x" Decode.float)
        (Decode.field "y" Decode.float)


extentDecoder : Decoder Extent
extentDecoder =
    Decode.map4 Extent
        (Decode.field "xmin" Decode.float)
        (Decode.field "ymin" Decode.float)
        (Decode.field "xmax" Decode.float)
        (Decode.field "ymax" Decode.float)
