module Msgs exposing (..)

import Navigation exposing (Location)

type Msg
  = OnGenerateRandomCircle Int Int
  | OnLocationChange Location
  | OnMousePositionChange Int Int
  | OnTimerCreateRandomCircle
  | OnWindowWidthChange Int
