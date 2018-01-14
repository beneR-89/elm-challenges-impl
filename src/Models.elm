module Models exposing (..)

type alias Position = {
  x : Int,
  y : Int
}

type alias Model = {
  blueCircles : List Position,
  mousePosition : Position,
  route : Route,
  windowWidth : Int
}

initialModel : Route -> Model
initialModel route =
  {
    blueCircles = [],
    mousePosition = { x = -1, y = -1 },
    route = route,
    windowWidth = -1
  }

type Route
  = HomeRoute
  | Challenge1Route
  | Challenge2Route
  | Challenge3Route
  | Challenge4Route
  | Challenge5Route
  | Challenge6Route
  | NotFoundRoute
