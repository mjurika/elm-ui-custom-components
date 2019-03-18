module Main exposing (main)

-- import CustomElement.DropdownButton as DropdownButton

import Browser
import Browser.Dom as Dom
import CustomElement.DropdownButton as DropdownButton exposing (Item)
import Html exposing (..)
import Html.Attributes exposing (..)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type alias Model =
    { title : String
    , items : List Item
    }


type Msg
    = Noop


init : () -> ( Model, Cmd Msg )
init () =
    ( { title = "Title from Elm"
      , items =
            [ { title = "one"
              , action = "on_oneClick"
              }
            , { title = "two"
              , action = "on_twoClick"
              }
            ]
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "UI custom components" ]
        , h2 [] [ text "Dropdown button" ]
        , DropdownButton.dropdownButton
            [ DropdownButton.dropdownTitle model.title
            , DropdownButton.dropdownItems model.items
            ]
            []
        ]
