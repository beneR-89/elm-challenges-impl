module Challenges.Common.SnakeGame exposing (createSnakeView)

import Html exposing (Html)
import Collage exposing (..)
import Element exposing (..)
import Color exposing (Color, rgb)
import Transform exposing (translation)

createSnakeView : Int -> Html msg
createSnakeView size =
  let
    sizeF = toFloat size
    squareSizeF = sizeF / (toFloat numSquaresPerRow)
    snakeForms = [snakeField sizeF, snakeSquares squareSizeF]
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
    move2Init = translation -offset offset
    rowIndices = List.range 1 numSquaresPerRow
    squareRow = \row -> snakeSquareRow squareSize row
  in
    groupTransform move2Init
      (rowIndices
        |> List.map (\row -> squareRow row)
        |> List.concatMap (\a -> a)
      )

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

moveSquare : Float -> Int -> Int -> Form -> Form
moveSquare squareSize row col field =
  let
    x = (toFloat (col - 1)) * squareSize
    y = -(toFloat (row - 1)) * squareSize
  in
    move (x, y) field

numSquaresPerRow : Int
numSquaresPerRow = 17

gameFieldGreen : Color
gameFieldGreen = rgb 50 150 50

gameFieldSquareGreen : Color
gameFieldSquareGreen = rgb 50 200 50
