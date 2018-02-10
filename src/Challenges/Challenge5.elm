module Challenges.Challenge5 exposing (..)

import Challenges.Common.Common exposing (backBtn)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, style)
import Models exposing (Model)
import Msgs exposing (Msg)

import Challenges.Common.SnakeGame exposing (createSnakeView)

view : Model -> Html Msg
view model =
  div [ class "container-fluid" ]
    [ backBtn
    , div [ class "row" ]
        [ div [ class "col-sm-2" ] []
        , div [ class "col-sm-8" ] [ snakeView model ]
        , div [ class "col-sm-2" ] []
        ]
    ]

snakeView : Model -> Html msg
snakeView model =
  let
    windowWidth = model.windowWidth - 30
    windowHeight = model.windowHeight - 55
    defaultSnakeSize = 482
    snakeSize = List.minimum [windowWidth, windowHeight, defaultSnakeSize]
  in
    case snakeSize of
      Just size ->
        div [ class "snakeViewContainer" ] [ createSnakeView size ]
      Nothing ->
        div [ class "snakeViewContainer" ] [ createSnakeView defaultSnakeSize ]
