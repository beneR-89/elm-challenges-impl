module Msgs exposing (..)

import Keyboard exposing (KeyCode)
import Navigation exposing (Location)

type Msg
  = OnGenerateRandomCircle Int Int
  | OnKeyPressed KeyCode
  | OnLocationChange Location
  | OnMousePositionChange Int Int
  | OnResetCircles
  | OnToggleCircleCreation
  | OnTimerCreateRandomCircle
  | OnWindowWidthChange Int
