module Main exposing (..)

import Char
import Keyboard exposing (KeyCode)
import Random exposing (Generator)
import Models exposing (..)
import Mouse
import Msgs exposing (Msg)
import Navigation exposing (Location)
import Routing
import Task
import Time exposing (Time)
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
    Msgs.OnGenerateRandomCircle x y ->
      let
        pos = Position x y
        blueCircles = model.blueCircles
      in
        ( { model | blueCircles = pos :: blueCircles }, Cmd.none )
    Msgs.OnKeyPressed keyCode ->
      handleKeyPressed model keyCode
    Msgs.OnLocationChange location ->
      let
        newRoute = Routing.parseLocation location
      in
        ( { model | route = newRoute }, Cmd.none )
    Msgs.OnMousePositionChange x y ->
      let
        pos = Position x y
      in
        ( { model | mousePosition = pos }, Cmd.none )
    Msgs.OnResetCircles ->
      resetCircles model
    Msgs.OnTimerCreateRandomCircle ->
      let
        singleGen = Random.int 0 100
        pairGen = Random.pair singleGen singleGen
      in
        ( model, Random.generate (\(x, y) -> Msgs.OnGenerateRandomCircle x y) pairGen )
    Msgs.OnToggleCircleCreation ->
      toggleCircleCreation model
    Msgs.OnWindowWidthChange width ->
      ( { model | windowWidth = width }, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  let
    drawCircles = drawRandomCircles model.route model.drawRandomCircles
  in
    if drawCircles then
      Sub.batch (circleTimeSub :: standardSubList)
    else
      Sub.batch standardSubList

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

standardSubList : List (Sub Msg)
standardSubList =
  [ Mouse.moves (\{x, y} -> Msgs.OnMousePositionChange x y)
  , Window.resizes (\size -> Msgs.OnWindowWidthChange size.width)
  , Keyboard.presses (\keyCode -> Msgs.OnKeyPressed keyCode)
  ]

circleTimeSub : Sub Msg
circleTimeSub =
  Time.every 2000 (\time -> Msgs.OnTimerCreateRandomCircle)

drawRandomCircles : Route -> Bool -> Bool
drawRandomCircles route drawRandomCircles =
  let
    isRouteOk = route == Challenge2Route || route == Challenge3Route
  in
    if route == Challenge3Route then
      isRouteOk && drawRandomCircles
    else
      isRouteOk

handleKeyPressed : Model -> KeyCode -> (Model, Cmd Msg)
handleKeyPressed model keyCode =
  let
    route = model.route
    isCircleChallenge = route == Challenge2Route || route == Challenge3Route
    key = Char.fromCode keyCode
  in
    if isCircleChallenge then
      if key == 'p' then
        toggleCircleCreation model
      else if key == 'r' then
        resetCircles model
      else
        ( model, Cmd.none )
    else
      ( model, Cmd.none )

resetCircles : Model -> (Model, Cmd msg)
resetCircles model =
  let
    isChallenge3 = model.route == Challenge3Route
  in
    if isChallenge3 then
      ( { model | blueCircles = [] }, Cmd.none )
    else
      ( model, Cmd.none )

toggleCircleCreation : Model -> (Model, Cmd msg)
toggleCircleCreation model =
  let
    drawCircles = model.drawRandomCircles
  in
    ( { model | drawRandomCircles = not drawCircles }, Cmd.none )
