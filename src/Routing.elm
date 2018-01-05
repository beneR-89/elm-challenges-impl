module Routing exposing (..)

import Models exposing (Route(..))
import Navigation exposing (Location)
import UrlParser exposing (..)

matchers : Parser (Route -> a) a
matchers =
  oneOf
    [ map HomeRoute top
    , map Challenge1Route (s ("challenge1"))
    , map Challenge2Route (s ("challenge2"))
    , map Challenge3Route (s ("challenge3"))
    , map Challenge4Route (s ("challenge4"))
    , map Challenge5Route (s ("challenge5"))
    , map Challenge6Route (s ("challenge6"))
    ]

parseLocation : Location -> Route
parseLocation location =
  case (parseHash matchers location) of
    Just route ->
      route
    Nothing ->
      NotFoundRoute

challengePath : Int -> String
challengePath challengeId =
  "#challenge" ++ toString challengeId
