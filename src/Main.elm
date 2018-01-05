module Main exposing (..)

import Html exposing (Html, div, text, program)
import Html.Attributes exposing (class)

type Msg = NoOp

type alias Model = String

initModel : Model
initModel = "Hello World!"

init : ( Model, Cmd Msg )
init = ( initModel, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp ->
      ( model, Cmd.none )

view : Model -> Html Msg
view model =
  div [ class "container-fluid" ]
    [ div [ class "row" ]
        [ div [ class "col-md-12 h1 text-center" ]
            [ text model ]
        ]
    ]

subscriptions : Model -> Sub Msg
subscriptions model = Sub.none

main : Program Never Model Msg
main = program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }
