module Challenges.Common.SnakeGame exposing (view, Model, initialModel, Msg, update, subscriptions)

import Html exposing (Html, div, text, h1, h2, p, button)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Collage exposing (circle, rect, collage, filled, Form, move, groupTransform)
import Element exposing (toHtml)
import Color exposing (Color, rgb)
import Transform exposing (translation)
import Keyboard exposing (KeyCode)
import Time exposing (Time)
import Random
import Challenges.Common.Highscore.Highscore as Highscore

type Direction = Top | Bottom | Left | Right

type alias Position = {
  row: Int,
  col: Int
}

type alias Model = {
  size: Int,
  headPosition: Position,
  bodyPositions: List Position,
  applePosition: Maybe Position,
  walkingDirection: Direction,
  isGameRunning: Bool,
  growLarger: Bool,
  highscoreModel: Highscore.Model
}

initialModel : Model
initialModel =
  {
    size = 482,
    headPosition = Position startRow startRow,
    bodyPositions = [Position startRow (startRow+1), Position startRow (startRow+2)],
    applePosition = Just (Position (startRow+1) (startRow-1)),
    walkingDirection = Left,
    isGameRunning = False,
    growLarger = False,
    highscoreModel = Highscore.initialModel
  }

type Msg
  = OnTimerMoveSnake
  | OnKeyPressed KeyCode
  | OnGenerateApple (Maybe Position)
  | OnStartGame
  | OnHighscoreMsg Highscore.Msg

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    OnTimerMoveSnake ->
      let
        score = getScore model.headPosition model.bodyPositions
        highscoreUpdate = model.highscoreModel
          |> Highscore.update (Highscore.OnNewScore score)
        highscoreModel = Tuple.first highscoreUpdate
        highscoreCmd = Tuple.second highscoreUpdate
        nextModel = model
          |> updateSnakePositions
          |> maybeEatApple
          |> updateApplePosition
          |> checkGameStatus
        cmd = if nextModel.growLarger then
          Cmd.batch
            [ Random.generate (\pos -> OnGenerateApple pos) (appleGenerator model.headPosition model.bodyPositions)
            , highscoreCmd ]
          else highscoreCmd
      in
        ( { nextModel | highscoreModel = highscoreModel }, cmd)
    OnKeyPressed keyCode ->
      ({ model | walkingDirection = updateWalkingDirection keyCode model.walkingDirection }, Cmd.none)
    OnGenerateApple position -> ({ model | applePosition = position }, Cmd.none)
    OnStartGame -> ({ model | isGameRunning = True }, Cmd.none)
    OnHighscoreMsg msg ->
      let
        highscoreUpdate = model.highscoreModel
          |> Highscore.update msg
        highscoreModel = Tuple.first highscoreUpdate
        highscoreCmd = Tuple.second highscoreUpdate
      in
        ({ model | highscoreModel = highscoreModel }, highscoreCmd)

mapHighscoreMsg : Highscore.Msg -> Msg
mapHighscoreMsg msg = OnHighscoreMsg msg

getScore : Position -> List Position -> Int
getScore head body = List.length (head :: body)

updateWalkingDirection : KeyCode -> Direction -> Direction
updateWalkingDirection keyCode oldDirection =
  case keyCode of
    38 -> Top
    40 -> Bottom
    37 -> Left
    39 -> Right
    _ -> oldDirection

updateSnakePositions : Model -> Model
updateSnakePositions model =
  let
    shift = if model.growLarger then 0 else 1
    body = model.bodyPositions
      |> List.take (List.length model.bodyPositions - shift)
      |> (::) model.headPosition
    head = updateHeadPosition model.walkingDirection model.headPosition
  in
    { model | bodyPositions = body, headPosition = head }

updateHeadPosition : Direction -> Position -> Position
updateHeadPosition direction position =
  case direction of
    Top -> Position (position.row - 1) position.col
    Bottom -> Position (position.row + 1) position.col
    Left -> Position position.row (position.col - 1)
    Right -> Position position.row (position.col + 1)

maybeEatApple : Model -> Model
maybeEatApple model =
  case model.applePosition of
    Just applePosition ->
      let
        shallEat = model.headPosition == applePosition
      in
        { model | growLarger = shallEat }
    Nothing -> { model | growLarger = False }

updateApplePosition : Model -> Model
updateApplePosition model = model

checkGameStatus : Model -> Model
checkGameStatus model =
  let
    hasLeftMatchField = boundaryRuleViolation model.headPosition
    isBodyCollision = snakeBodyRuleViolation model.headPosition model.bodyPositions
    gameOver = hasLeftMatchField || isBodyCollision
  in
    if gameOver then initialModel else model

boundaryRuleViolation : Position -> Bool
boundaryRuleViolation head =
  let
    rowViolation = head.row < 1 || head.row > numSquaresPerRow
    colViolation = head.col < 1 || head.col > numSquaresPerRow
  in
    rowViolation || colViolation

snakeBodyRuleViolation : Position -> List Position -> Bool
snakeBodyRuleViolation head body =
  List.any (\bodyPos -> bodyPos == head) body

appleGenerator : Position -> List Position -> Random.Generator (Maybe Position)
appleGenerator head body =
  let
    currentSnakeSize = List.length body + 1
    numFields = numSquaresPerRow * numSquaresPerRow
    numFreeFields = numFields - currentSnakeSize
    intGenerator = Random.int 1 numFreeFields
    getPosition = head :: body |> positionFromFreeFieldIndex
  in
    intGenerator |> Random.map (\(idx) -> getPosition idx)

positionFromFreeFieldIndex : List Position -> Int -> Maybe Position
positionFromFreeFieldIndex occupiedFields index =
  let
    occupiedFieldIndices = occupiedFields |> List.map fieldIndex
    freeIndices = (List.range 1 (numSquaresPerRow * numSquaresPerRow))
      |> List.filter (\idx -> not (List.member idx occupiedFieldIndices))
    mappedIndex = if index <= List.length freeIndices then
      freeIndices
        |> List.drop (index-1)
        |> List.head
      else Nothing
  in
    case mappedIndex of
      Just idx -> Just (fieldPosition idx)
      Nothing -> Nothing

fieldIndex : Position -> Int
fieldIndex position =
  (position.row - 1) * numSquaresPerRow + position.col

fieldPosition : Int -> Position
fieldPosition index =
  let
    row = (index-1) // numSquaresPerRow
    col = rem (index-1) numSquaresPerRow
  in
    Position (row+1) (col+1)

subscriptions : Model -> Sub Msg
subscriptions model =
  if model.isGameRunning then
    Sub.batch
      [ Keyboard.downs (\keyCode -> OnKeyPressed keyCode)
      , Time.every 500 (\time -> OnTimerMoveSnake)
      ]
  else
    model.highscoreModel |> Highscore.subscriptions |> Sub.map mapHighscoreMsg

view : Model -> Html Msg
view model =
  let
    snakeView = createSnakeView model
  in
    if model.isGameRunning then
      div [] [ snakeView ]
    else
      div [] [ startScreen model.highscoreModel ]

startScreen : Highscore.Model -> Html Msg
startScreen highscoreModel =
  div [ class "jumbotron" ]
    [ h1 [] [ text "Welcome to Snake!" ]
    , h2 [ class "text-primary" ]
        [ toString highscoreModel.highscore
            |> String.append "Your current highscore is: "
            |> text
        ]
    , h2 [] [ text "Click Go to start a new game" ]
    , p []
        [ button [ onClick OnStartGame, class "btn btn-primary" ] [ text "Go" ]
        ]
    ]

createSnakeView : Model -> Html msg
createSnakeView model =
  let
    size = model.size
    sizeF = toFloat size
    squareSizeF = sizeF / (toFloat numSquaresPerRow)
    head = snakeHead squareSizeF model.headPosition
    body = snakeBodyElements squareSizeF model.bodyPositions
  in
    case model.applePosition of
      Just applePosition ->
        let
          apple = snakeApple squareSizeF applePosition
          snakeForms = [snakeField sizeF, snakeSquares squareSizeF, apple, body, head]
        in
          toHtml (collage size size snakeForms)
      Nothing ->
        let
          snakeForms = [snakeField sizeF, snakeSquares squareSizeF, body, head]
        in
          toHtml (collage size size snakeForms)

snakeField : Float -> Form
snakeField size =
  filled gameFieldGreen (rect size size)

snakeSquares : Float -> Form
snakeSquares squareSize =
  let
    rowCountF = toFloat numSquaresPerRow
    offset = rowCountF * squareSize * 0.5 - squareSize * 0.5
    rowIndices = List.range 1 numSquaresPerRow
    squareRow = \row -> snakeSquareRow squareSize row
    forms = rowIndices
      |> List.map (\row -> squareRow row)
      |> List.concatMap (\a -> a)
  in
    move2Init squareSize forms

snakeSquareRow : Float -> Int -> List Form
snakeSquareRow squareSize row =
  let
    move = moveSquare squareSize row
    square = snakeSquare squareSize
    showSquare = \col -> if col % 2 == row % 2 then Just col else Nothing
    colIndices = List.filterMap showSquare (List.range 1 numSquaresPerRow)
  in
    List.map (\col -> move col square) colIndices

snakeSquare : Float -> Form
snakeSquare size =
  filled gameFieldSquareGreen (rect size size)

snakeApple : Float -> Position -> Form
snakeApple size position =
  let
    apple = circleElement size position appleRed
  in
    move2Init size [apple]

snakeHead : Float -> Position -> Form
snakeHead size position =
  let
    head = circleElement size position snakeHeadBlue
  in
    move2Init size [head]

snakeBodyElements : Float -> List Position -> Form
snakeBodyElements size positions =
  let
    createBodyElement = snakeBodyElement size
    bodyElements = List.map createBodyElement positions
  in
    move2Init size bodyElements

snakeBodyElement : Float -> Position -> Form
snakeBodyElement size position =
  circleElement size position snakeBlue

circleElement : Float -> Position -> Color -> Form
circleElement size position color =
  let
    radius = 0.5 * size
    coloredCircle = filled color (circle radius)
  in
    coloredCircle |> (moveSquare size position.row position.col)

moveSquare : Float -> Int -> Int -> Form -> Form
moveSquare squareSize row col field =
  let
    x = (toFloat (col - 1)) * squareSize
    y = -(toFloat (row - 1)) * squareSize
  in
    move (x, y) field

move2Init : Float -> List Form -> Form
move2Init squareSize forms =
  let
    rowCountF = toFloat numSquaresPerRow
    offset = rowCountF * squareSize * 0.5 - squareSize * 0.5
    tMat = translation -offset offset
  in
    groupTransform tMat forms

startRow : Int
startRow = numSquaresPerRow // 2

numSquaresPerRow : Int
numSquaresPerRow = 10

gameFieldGreen : Color
gameFieldGreen = rgb 50 150 50

gameFieldSquareGreen : Color
gameFieldSquareGreen = rgb 50 200 50

appleRed : Color
appleRed = rgb 200 0 0

snakeBlue : Color
snakeBlue = rgb 0 0 250

snakeHeadBlue : Color
snakeHeadBlue = rgb 0 0 100
