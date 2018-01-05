module Challenges.Challenge1 exposing (..)

import Html exposing (Html, div, text)
import Models exposing (Model)
import Msgs exposing (Msg)

view : Model -> Html Msg
view model =
  div [] [ text "Challenge 1" ]
