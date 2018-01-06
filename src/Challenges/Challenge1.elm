module Challenges.Challenge1 exposing (..)

import Challenges.Common.Common exposing (backBtn)
import Html exposing (Attribute, Html, div, text, p)
import Html.Attributes exposing (class, attribute)
import Models exposing (Model)
import Msgs exposing (Msg)

view : Model -> Html Msg
view model =
  div [ class "container-fluid" ]
    [ backBtn
    , div [ class "jumbotron challenge1-bg", mousePosAttr model ]
        [ p [ class "text-center h1 challenge1-text", mousePosAttr model ]
            [ model
                |> getDisplayText
                |> text
            ]
        ]
    ]

getDisplayText : Model -> String
getDisplayText model =
  let
    x = model.mousePosition.x
    width = model.windowWidth
  in
    if isLeftSide x width then
      "LEFT"
    else "RIGHT"

isLeftSide : Int -> Int -> Bool
isLeftSide x width =
  let
    centerX = width // 2
  in
    x < centerX

mousePosAttr : Model -> Attribute msg
mousePosAttr model =
  let
    x = model.mousePosition.x
    width = model.windowWidth
    attr = attribute mousePosAttrName
  in
    if isLeftSide x width then
      attr "left"
    else attr "right"

mousePosAttrName : String
mousePosAttrName = "data-pos"
