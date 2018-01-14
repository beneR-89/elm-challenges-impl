module Challenges.Challenge2 exposing (..)

import Challenges.Common.Common exposing (backBtn, blueCircle)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, style)
import Models exposing (Model, Position)
import Msgs exposing (Msg)

view : Model -> Html Msg
view model =
  let
    blueCircles = model.blueCircles |> List.map blueCircle
  in
    div [ class "container-fluid" ]
      [ backBtn
      , div [] blueCircles
      ]
