module View exposing (..)

import Challenges.Challenge1 as Challenge1
import Challenges.Challenge2 as Challenge2
import Challenges.Challenge3 as Challenge3
import Challenges.Challenge4 as Challenge4
import Challenges.Challenge5 as Challenge5
import Challenges.Challenge6 as Challenge6
import Html exposing (Html, div, text, nav, ul, li, a, p, h1)
import Html.Attributes exposing (class, href)
import Models exposing (Model)
import Msgs exposing (Msg)
import Routing exposing (challengePath)

view : Model -> Html Msg
view model = page model

page : Model -> Html Msg
page model =
  case model.route of
    Models.HomeRoute -> homeView model
    Models.Challenge1Route -> Challenge1.view model
    Models.Challenge2Route -> Challenge2.view model
    Models.Challenge3Route -> Challenge3.view model
    Models.Challenge4Route -> Challenge4.view model
    Models.Challenge5Route -> Challenge5.view model
    Models.Challenge6Route -> Challenge6.view model
    Models.NotFoundRoute -> homeView model

homeView : Model -> Html Msg
homeView model =
  div [ class "fill" ]
    [ challengeNav
    , challengeHomeBody
    ]

challengeNav : Html Msg
challengeNav =
  nav [ class "navbar navbar-default mb-0 challengeNav" ]
    [ div [ class "container-fluid" ]
        [ div [ class "" ]
            [ ul [ class "nav navbar-nav" ]
                [ li [ class "active" ]
                    [ a [ href "" ] [ text "Home" ] ]
                    , challengeNavItem 1
                    , challengeNavItem 2
                    , challengeNavItem 3
                    , challengeNavItem 4
                    , challengeNavItem 5
                    , challengeNavItem 6
                ]
            ]
        ]
    ]

challengeHomeBody : Html Msg
challengeHomeBody =
  div [ class "jumbotron challengeHomeBody" ]
    [ div [ class "container" ]
        [ h1 [] [ text "Elm Challenges" ]
        , p [] [ text "Click on one item in the navigation bar above to view the result of the implementation of the specific challenge in action" ]
        ]
    ]

challengeNavItem : Int -> Html msg
challengeNavItem challengeId =
  let
    path = challengePath challengeId
    name = "Challenge " ++ toString challengeId
  in
    li [] [ a [ href path ] [ text name ] ]
