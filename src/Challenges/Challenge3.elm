module Challenges.Challenge3 exposing (..)

import Challenges.Common.Common exposing (backBtn, blueCircle)
import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class, tabindex, id)
import Html.Events exposing (onClick)
import Models exposing (Model)
import Msgs exposing (Msg)

view : Model -> Html Msg
view model =
  let
    blueCircles = model.blueCircles |> List.map blueCircle
  in
    div [ class "container-fluid" ]
      [ backBtn
      , circleCmdBtns
      , div [] blueCircles
      ]

circleCmdBtns : Html Msg
circleCmdBtns =
  div [ class "circleCommandButtons" ]
    [ button
        [ onClick Msgs.OnToggleCircleCreation
        , class circleCmdBtnClass ] [ text "toggle circle creation (P)" ]
    , button
        [ onClick Msgs.OnResetCircles
        , class circleCmdBtnClass ] [ text "reset (R)" ]
    ]

circleCmdBtnClass : String
circleCmdBtnClass = "btn btn-default circleCommandButton"
