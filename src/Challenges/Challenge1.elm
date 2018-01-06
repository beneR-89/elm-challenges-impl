module Challenges.Challenge1 exposing (..)

import Challenges.Common.Common exposing (backBtn)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Models exposing (Model)
import Msgs exposing (Msg)

view : Model -> Html Msg
view model =
  div [ class "container-fluid" ]
    [ backBtn
    , div [] [] ]
