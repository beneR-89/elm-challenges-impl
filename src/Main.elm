module Main exposing (..)

import Models exposing (..)
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Routing
import View exposing (view)

init : Location -> ( Model, Cmd Msg )
init location =
  let
    currentRoute = Routing.parseLocation location
  in
    ( initialModel currentRoute, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Msgs.OnLocationChange location ->
      let
        newRoute = Routing.parseLocation location
      in
        ( { model | route = newRoute }, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : Program Never Model Msg
main = Navigation.program Msgs.OnLocationChange
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }
