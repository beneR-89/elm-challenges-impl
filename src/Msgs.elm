module Msgs exposing (..)

import Navigation exposing (Location)

type Msg
  = OnLocationChange Location
  | OnMousePositionChange Int Int
  | OnWindowWidthChange Int
