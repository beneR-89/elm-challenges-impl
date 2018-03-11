module Main exposing (..)

import Char
import Http
import Json.Decode as Decode
import Keyboard exposing (KeyCode)
import Process
import Random exposing (Generator)
import Models exposing (..)
import Mouse
import Msgs exposing (Msg)
import Navigation exposing (Location)
import RemoteData
import Routing
import Task
import Time exposing (Time)
import View exposing (view)
import Window
import Challenges.Common.SnakeGame as SnakeGame

init : Location -> ( Model, Cmd Msg )
init location =
  let
    currentRoute = Routing.parseLocation location
  in
    ( initialModel currentRoute, windowWidthCmd )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Msgs.OnChangeGithubUserNameToSearch newName ->
      let
        currentSearchId = model.githubUserSearch.id
        newSearchId = currentSearchId + 1
        searchObj = { id = newSearchId, search = newName }
      in
        ( { model | githubUserSearch = searchObj }
        , waitForGithubUserToSearch searchObj )
    Msgs.OnGenerateRandomCircle x y ->
      let
        pos = Position x y
        blueCircles = model.blueCircles
      in
        ( { model | blueCircles = pos :: blueCircles }, Cmd.none )
    Msgs.OnGithubUserInfo response ->
      case response of
        RemoteData.Success userInfo ->
          ( { model | githubUser = response }, getGithubUserLanguages userInfo.fetchReposUrl )
        RemoteData.NotAsked ->
          ( { model | githubUser = response
            , githubUserLanguages = RemoteData.NotAsked }, Cmd.none )
        RemoteData.Loading ->
          ( { model | githubUser = response
            , githubUserLanguages = RemoteData.NotAsked }, Cmd.none )
        RemoteData.Failure err ->
          ( { model | githubUser = response
            , githubUserLanguages = RemoteData.NotAsked }, Cmd.none )
    Msgs.OnGithubUserRepos response ->
      ( { model | githubUserLanguages = response }, Cmd.none )
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
    Msgs.OnSearchGithubUser lastSearch ->
      let
        currentSearchId = model.githubUserSearch.id
        currentSearchName = model.githubUserSearch.search
        searchGithubUser = lastSearch.id == currentSearchId && currentSearchName /= ""
      in
        if searchGithubUser then
          ( model, getGithubUserInfo currentSearchName )
        else
          ( { model | githubUser = RemoteData.NotAsked
            , githubUserLanguages = RemoteData.NotAsked }, Cmd.none )
    Msgs.OnTimerCreateRandomCircle ->
      let
        singleGen = Random.int 0 100
        pairGen = Random.pair singleGen singleGen
      in
        ( model, Random.generate (\(x, y) -> Msgs.OnGenerateRandomCircle x y) pairGen )
    Msgs.OnToggleCircleCreation ->
      toggleCircleCreation model
    Msgs.OnWindowSizeChange size ->
      let
        width = size.width
        height = size.height
        initialSnakeModel = SnakeGame.initialModel
        currentSnakeModel = model.snakeModel
        snakeFieldSize = List.minimum [width-30, height-55, initialSnakeModel.size]
      in
        case snakeFieldSize of
          Just size ->
            let
              snakeModel = { currentSnakeModel | size = size }
            in
              ( { model | windowWidth = width, windowHeight = height, snakeModel = snakeModel }, Cmd.none)
          Nothing ->
            let
              snakeModel = { currentSnakeModel | size = initialSnakeModel.size }
            in
              ( { model | windowWidth = width, windowHeight = height, snakeModel = snakeModel }, Cmd.none)
    Msgs.SnakeMessage msg ->
      let
        snakeUpdate = model.snakeModel |> SnakeGame.update msg
        snakeModel = Tuple.first snakeUpdate
        snakeCmd = Tuple.second snakeUpdate |> Cmd.map Msgs.mapSnakeMsg
      in
        ( { model | snakeModel = snakeModel }, snakeCmd)

subscriptions : Model -> Sub Msg
subscriptions model =
  let
    drawCircles = drawRandomCircles model.route model.drawRandomCircles
    snakeSub = model.snakeModel
      |> SnakeGame.subscriptions
      |> Sub.map Msgs.mapSnakeMsg
    subList = if model.route == Challenge5Route then snakeSub :: standardSubList else standardSubList
  in
    if drawCircles then
      Sub.batch (circleTimeSub :: subList)
    else
      Sub.batch subList

main : Program Never Model Msg
main = Navigation.program Msgs.OnLocationChange
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

windowWidthCmd : Cmd Msg
windowWidthCmd =
  Task.perform Msgs.OnWindowSizeChange Window.size

standardSubList : List (Sub Msg)
standardSubList =
  [ Mouse.moves (\{x, y} -> Msgs.OnMousePositionChange x y)
  , Window.resizes (\size -> Msgs.OnWindowSizeChange size)
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

waitForGithubUserToSearch : GithubUserSearch -> Cmd Msg
waitForGithubUserToSearch lastSearch =
  Process.sleep Time.second
  |> Task.andThen (always <| Task.succeed (Msgs.OnSearchGithubUser lastSearch))
  |> Task.perform identity

getGithubUserInfo : String -> Cmd Msg
getGithubUserInfo userName =
  let
    url = fetchGithubUserUrl userName
  in
    Http.get url decodeGithubUserInfo
      |> RemoteData.sendRequest
      |> Cmd.map Msgs.OnGithubUserInfo

getGithubUserLanguages : String -> Cmd Msg
getGithubUserLanguages userReposUrl =
  Http.get userReposUrl decodeGithubUserReposInfo
    |> RemoteData.sendRequest
    |> Cmd.map Msgs.OnGithubUserRepos

decodeGithubUserInfo : Decode.Decoder GithubUser
decodeGithubUserInfo =
  Decode.map3 GithubUser
    (Decode.field "avatar_url" Decode.string)
    (Decode.field "repos_url" Decode.string)
    (Decode.field "name" Decode.string)

decodeGithubUserReposInfo : Decode.Decoder (List String)
decodeGithubUserReposInfo =
  (Decode.list (Decode.field "language" Decode.string))
