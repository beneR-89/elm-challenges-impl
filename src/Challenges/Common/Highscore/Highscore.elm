port module Challenges.Common.Highscore.Highscore exposing (..)

type alias Score = Int

type alias Model = {
  highscore: Score
}

type Msg
  = OnInitialScore Score
  | OnNewScore Score
  | NoOp

initialModel : Model
initialModel = { highscore = 0 }

update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  case msg of
    OnInitialScore score ->
      ({ model | highscore = score }, Cmd.none)
    OnNewScore score ->
      if score > model.highscore then
        ({ model | highscore = score }, saveHighscore score)
      else
        (model, Cmd.none)
    NoOp -> (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  initialHighscore (\highscore -> restoreHighscore highscore)

restoreHighscore : String -> Msg
restoreHighscore highscoreStr =
  let
    highscore = String.toInt highscoreStr
  in
    case highscore of
      Ok score -> OnInitialScore score
      Err error -> NoOp

port initialHighscore : (String -> msg) -> Sub msg

port saveHighscore : Score -> Cmd msg
