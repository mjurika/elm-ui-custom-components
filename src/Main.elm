module Main exposing (main)

import Browser
import Browser.Dom as Dom
import CustomElement.AutoComplete as AutoComplete exposing (..)
import CustomElement.DropdownButton as DropdownButton exposing (..)
import CustomElement.GeoLocation as GeoLocation exposing (..)
import CustomElement.MapView as MapView exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, field, string)
import Round



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
    , status : Status
    , autoCompleteLabel : String
    , value : String
    , geometryStatus : GeometryStatus
    , measureType : String
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
    ( { title = "Change basemap"
      , items =
            [ { title = "Hybrid"
              , baseMap = "hybrid"
              }
            , { title = "Streets"
              , baseMap = "streets"
              }
            , { title = "Satellite"
              , baseMap = "satellite"
              }
            , { title = "Topographic"
              , baseMap = "topo"
              }
            ]
      , baseMap = "hybrid"
      , triggerPosition = 0
      , position = Nothing
      , status = Loading
      , autoCompleteLabel = "Search in map"
      , value = ""
      , geometryStatus = LoadingGeom
      , measureType = "none"
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Noop
    | OnClick String
    | TriggerPosition
    | Position Position
    | GotResult (Result Http.Error (List SuggestResult))
    | OnInput String
    | OnAutocomplete String
    | GotGeometry (Result Http.Error (List Geometry))
    | MeasureDistance
    | MeasureArea
    | MeasureNone


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

        MeasureDistance ->
            ( { model | measureType = "distance" }
            , Cmd.none
            )

        MeasureArea ->
            ( { model | measureType = "area" }
            , Cmd.none
            )

        MeasureNone ->
            ( { model | measureType = "none" }
            , Cmd.none
            )


positionToString : Maybe Position -> String
positionToString position =
    case position of
        Nothing ->
            "Lat: -, Long: -, Acc: -"

        Just p ->
            "Lat: "
                ++ Round.round 4 p.latitude
                ++ ", Long: "
                ++ Round.round 4 p.longitude
                ++ ", Acc: "
                ++ String.fromFloat p.accuracy



-- VIEW


view : Model -> Html Msg
view model =
    main_ []
        [ div [ class "top-bar" ]
            [ div []
                [ AutoComplete.autoComplete
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
            , div []
                [ DropdownButton.dropdownButton
                    [ DropdownButton.dropdownTitle model.title
                    , DropdownButton.dropdownItems model.items
                    , DropdownButton.onClick OnClick
                    ]
                    []
                , div []
                    [ span []
                        [ text "Selected: " ]
                    , strong []
                        [ text model.baseMap ]
                    ]
                ]
            , div []
                [ button
                    [ class "btn"
                    , onClick TriggerPosition
                    ]
                    [ text "Show my location"
                    , i [ class "material-icons left" ]
                        [ text "my_location" ]
                    ]
                , GeoLocation.geoLocation
                    [ GeoLocation.triggerPosition model.triggerPosition
                    , GeoLocation.onPosition Position
                    ]
                    []
                , div []
                    [ span []
                        [ text "Your location: " ]
                    , strong []
                        [ text <| positionToString model.position ]
                    ]
                ]
            , div []
                [ div []
                    [ span [ class "label" ]
                        [ text "Meranie" ]
                    ]
                , div [ class model.measureType ]
                    [ button
                        [ class "btn btn-flat"
                        , id "distance"
                        , title "Measure distance between two points"
                        , onClick MeasureDistance
                        ]
                        [ i [ class "material-icons" ]
                            [ text "remove" ]
                        ]
                    , button
                        [ class "btn btn-flat"
                        , id "area"
                        , title "Measure area"
                        , onClick MeasureArea
                        ]
                        [ i [ class "material-icons" ]
                            [ text "details" ]
                        ]
                    , button
                        [ class "btn btn-flat"
                        , id "none"
                        , title "Close measurement"
                        , onClick MeasureNone
                        ]
                        [ i [ class "material-icons" ]
                            [ text "close" ]
                        ]
                    ]
                ]
            , div [ class "logo-wrapper" ]
                [ img [ src "../images/elm-map-logo.png", width 150, height 60 ] [] ]
            ]
        , div [ class "map-container" ]
            [ MapView.mapView
                [ MapView.baseMap model.baseMap
                , MapView.position model.position
                , MapView.measurement model.measureType
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
