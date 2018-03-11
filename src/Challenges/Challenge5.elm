module Challenges.Challenge5 exposing (..)

import Challenges.Common.Common exposing (backBtn)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, style)
import Models exposing (Model)
import Msgs exposing (Msg)

import Challenges.Common.SnakeGame as SnakeGame

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

snakeView : Model -> Html Msg
snakeView model =
  div [ class "snakeViewContainer" ]
    [ model.snakeModel
        |> SnakeGame.view
        |> Html.map Msgs.mapSnakeMsg
    ]
