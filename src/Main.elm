module Main exposing (main)

import Browser
import Browser.Dom as Dom
import CustomElement.DropdownButton as DropdownButton exposing (Item)
import Html exposing (..)
import Html.Attributes exposing (..)



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
    , action : String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { title = "Title from Elm"
      , items =
            [ { title = "one"
              , action = "btn-one-clicked"
              }
            , { title = "two"
              , action = "btn-two-clicked"
              }
            ]
      , action = "None"
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Noop
    | OnClick String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        OnClick action ->
            ( { model | action = action }
            , Cmd.none
            )



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
            [ text model.action ]
        ]
