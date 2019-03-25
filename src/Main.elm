module Main exposing (main)

import Browser
import Browser.Dom as Dom
import CustomElement.DropdownButton as DropdownButton exposing (Item)
import CustomElement.GeoLocation as GeoLocation exposing (Position)
import CustomElement.MapView as MapView exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)



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
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { title = "Title from Elm"
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
      , baseMap = "streets"
      , triggerPosition = 0
      , position = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Noop
    | OnClick String
    | TriggerPosition
    | Position Position


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



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "UI custom components" ]
        , h2 [] [ text "Dropdown button" ]
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
        , button [ onClick TriggerPosition ]
            [ text "Trigger Coordinates" ]
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
        , MapView.mapView
            [ MapView.baseMap model.baseMap
            ]
            []
        ]
