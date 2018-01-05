module Models exposing (..)

type alias Model = {
  route : Route
}

initialModel : Route -> Model
initialModel route =
  {
    route = route
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
