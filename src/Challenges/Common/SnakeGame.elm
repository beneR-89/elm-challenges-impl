module Challenges.Common.SnakeGame exposing (createSnakeView, Model)

import Html exposing (Html)
import Collage exposing (..)
import Element exposing (..)
import Color exposing (Color, rgb)
import Transform exposing (translation)

type alias Position = {
  row: Int,
  col: Int
}

type alias Model = {
  size: Int
}

createSnakeView : Model -> Html msg
createSnakeView model =
  let
    size = model.size
    sizeF = toFloat size
    squareSizeF = sizeF / (toFloat numSquaresPerRow)
    head = snakeHead squareSizeF (Position 1 5)
    positions = [Position 1 6, Position 1 7, Position 1 8, Position 2 8]
    body = snakeBodyElements squareSizeF positions
    apple = snakeApple squareSizeF (Position 1 4)
    snakeForms = [snakeField sizeF, snakeSquares squareSizeF, head, body, apple]
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
