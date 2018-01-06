module Main exposing (..)

import Models exposing (..)
import Mouse
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Routing
import Task
import View exposing (view)
import Window

init : Location -> ( Model, Cmd Msg )
init location =
  let
    currentRoute = Routing.parseLocation location
  in
    ( initialModel currentRoute, windowWidthCmd )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Msgs.OnLocationChange location ->
      let
        newRoute = Routing.parseLocation location
      in
        ( { model | route = newRoute }, Cmd.none )
    Msgs.OnMousePositionChange x y ->
      let
        pos = { x = x, y = y }
      in
        ( { model | mousePosition = pos }, Cmd.none )
    Msgs.OnWindowWidthChange width ->
      ( { model | windowWidth = width }, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ Mouse.moves (\{x, y} -> Msgs.OnMousePositionChange x y)
    , Window.resizes (\size -> Msgs.OnWindowWidthChange size.width)
    ]

main : Program Never Model Msg
main = Navigation.program Msgs.OnLocationChange
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

windowWidthCmd : Cmd Msg
windowWidthCmd =
  Task.perform Msgs.OnWindowWidthChange Window.width
