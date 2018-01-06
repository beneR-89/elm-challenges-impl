module Challenges.Common.Common exposing (..)

import Html exposing (Html, div, a, i, span, text)
import Html.Attributes exposing (class, href)
import Msgs exposing (Msg)
import Routing exposing (homePath)

backBtn : Html Msg
backBtn =
  div [ class "row" ]
    [ div [ class "col-md-1" ]
        [ a [ href homePath ]
            [ i [ class "fa fa-chevron-left backBtnIcon" ]
                [ span [ class "text-uppercase h4 backBtnText" ] [ text "Back" ] ] ] ]
    , div [ class "col-md-11"] []]
