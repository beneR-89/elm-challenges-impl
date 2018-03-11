module Challenges.Common.SnakeGame exposing (view, Model, initialModel, Msg, update, subscriptions)

import Html exposing (Html, div, text, h1, p, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Collage exposing (circle, rect, collage, filled, Form, move, groupTransform)
import Element exposing (toHtml)
import Color exposing (Color, rgb)
import Transform exposing (translation)
import Keyboard exposing (KeyCode)
import Time exposing (Time)

type Direction = Top | Bottom | Left | Right

type alias Position = {
  row: Int,
  col: Int
}

type alias Model = {
  size: Int,
  headPosition: Position,
  bodyPositions: List Position,
  applePosition: Position,
  walkingDirection: Direction,
  isGameRunning: Bool
}

initialModel : Model
initialModel =
  {
    size = 482,
    headPosition = Position 9 9,
    bodyPositions = [Position 9 10],
    applePosition = Position 9 4,
    walkingDirection = Left,
    isGameRunning = False
  }

type Msg
  = OnTimerMoveSnake
  | OnKeyPressed KeyCode
  | OnStartGame
  | OnStopGame

update : Msg -> Model -> Model
update msg model =
  case msg of
    OnTimerMoveSnake ->
      let
        nextModel = model
          |> updateSnakePositions
          |> updateApplePosition
          |> checkGameStatus
      in
        nextModel
    OnKeyPressed keyCode ->
      { model | walkingDirection = updateWalkingDirection keyCode model.walkingDirection }
    OnStartGame -> { model | isGameRunning = True }
    OnStopGame -> { model | isGameRunning = False }

updateWalkingDirection : KeyCode -> Direction -> Direction
updateWalkingDirection keyCode oldDirection =
  case keyCode of
    38 -> Top
    40 -> Bottom
    37 -> Left
    39 -> Right
    _ -> oldDirection

updateSnakePositions : Model -> Model
updateSnakePositions model =
  let
    body = model.bodyPositions
      |> List.take (List.length model.bodyPositions - 1)
      |> (::) model.headPosition
    head = updateHeadPosition model.walkingDirection model.headPosition
  in
    { model | bodyPositions = body, headPosition = head }

updateHeadPosition : Direction -> Position -> Position
updateHeadPosition direction position =
  case direction of
    Top -> Position (position.row - 1) position.col
    Bottom -> Position (position.row + 1) position.col
    Left -> Position position.row (position.col - 1)
    Right -> Position position.row (position.col + 1)

updateApplePosition : Model -> Model
updateApplePosition model = model

checkGameStatus : Model -> Model
checkGameStatus model = model

subscriptions : Model -> Sub Msg
subscriptions model =
  if model.isGameRunning then
    Sub.batch
      [ Keyboard.downs (\keyCode -> OnKeyPressed keyCode)
      , Time.every 2000 (\time -> OnTimerMoveSnake)
      ]
  else
    Sub.none

view : Model -> Html Msg
view model =
  let
    snakeView = createSnakeView model
  in
    if model.isGameRunning then
      div [] [ snakeView ]
    else
      div [] [ startScreen ]

startScreen : Html Msg
startScreen =
  div [ class "jumbotron" ]
    [ h1 [] [ text "Welcome to Snake!" ]
    , p [] [ text "Click Go to start a new game" ]
    , p []
        [ button [ onClick OnStartGame, class "btn btn-primary" ] [ text "Go" ]
        ]
    ]

createSnakeView : Model -> Html msg
createSnakeView model =
  let
    size = model.size
    sizeF = toFloat size
    squareSizeF = sizeF / (toFloat numSquaresPerRow)
    head = snakeHead squareSizeF model.headPosition
    body = snakeBodyElements squareSizeF model.bodyPositions
    apple = snakeApple squareSizeF model.applePosition
    snakeForms = [snakeField sizeF, snakeSquares squareSizeF, apple, body, head]
  in
    toHtml (collage size size snakeForms)

snakeField : Float -> Form
snakeField size =
  filled gameFieldGreen (rect size size)

snakeSquares : Float -> Form
snakeSquares squareSize =
  let
    rowCountF = toFloat numSquaresPerRow
    offset = rowCountF * squareSize * 0.5 - squareSize * 0.5
    rowIndices = List.range 1 numSquaresPerRow
    squareRow = \row -> snakeSquareRow squareSize row
    forms = rowIndices
      |> List.map (\row -> squareRow row)
      |> List.concatMap (\a -> a)
  in
    move2Init squareSize forms

snakeSquareRow : Float -> Int -> List Form
snakeSquareRow squareSize row =
  let
    move = moveSquare squareSize row
    square = snakeSquare squareSize
    showSquare = \col -> if col % 2 == row % 2 then Just col else Nothing
    colIndices = List.filterMap showSquare (List.range 1 numSquaresPerRow)
  in
    List.map (\col -> move col square) colIndices

snakeSquare : Float -> Form
snakeSquare size =
  filled gameFieldSquareGreen (rect size size)

snakeApple : Float -> Position -> Form
snakeApple size position =
  let
    apple = circleElement size position appleRed
  in
    move2Init size [apple]

snakeHead : Float -> Position -> Form
snakeHead size position =
  let
    head = circleElement size position snakeHeadBlue
  in
    move2Init size [head]

snakeBodyElements : Float -> List Position -> Form
snakeBodyElements size positions =
  let
    createBodyElement = snakeBodyElement size
    bodyElements = List.map createBodyElement positions
  in
    move2Init size bodyElements

snakeBodyElement : Float -> Position -> Form
snakeBodyElement size position =
  circleElement size position snakeBlue

circleElement : Float -> Position -> Color -> Form
circleElement size position color =
  let
    radius = 0.5 * size
    coloredCircle = filled color (circle radius)
  in
    coloredCircle |> (moveSquare size position.row position.col)

moveSquare : Float -> Int -> Int -> Form -> Form
moveSquare squareSize row col field =
  let
    x = (toFloat (col - 1)) * squareSize
    y = -(toFloat (row - 1)) * squareSize
  in
    move (x, y) field

move2Init : Float -> List Form -> Form
move2Init squareSize forms =
  let
    rowCountF = toFloat numSquaresPerRow
    offset = rowCountF * squareSize * 0.5 - squareSize * 0.5
    tMat = translation -offset offset
  in
    groupTransform tMat forms

numSquaresPerRow : Int
numSquaresPerRow = 17

gameFieldGreen : Color
gameFieldGreen = rgb 50 150 50

gameFieldSquareGreen : Color
gameFieldSquareGreen = rgb 50 200 50

appleRed : Color
appleRed = rgb 200 0 0

snakeBlue : Color
snakeBlue = rgb 0 0 250

snakeHeadBlue : Color
snakeHeadBlue = rgb 0 0 100
