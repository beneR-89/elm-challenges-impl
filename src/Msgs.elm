module Msgs exposing (..)

import Keyboard exposing (KeyCode)
import Models exposing (GithubUser, GithubUserSearch)
import Navigation exposing (Location)
import RemoteData exposing (WebData)
import Window exposing (Size)
import Challenges.Common.SnakeGame as SnakeGame

type Msg
  = OnChangeGithubUserNameToSearch String
  | OnGenerateRandomCircle Int Int
  | OnGithubUserInfo (WebData GithubUser)
  | OnGithubUserRepos (WebData (List String))
  | OnKeyPressed KeyCode
  | OnLocationChange Location
  | OnMousePositionChange Int Int
  | OnResetCircles
  | OnSearchGithubUser GithubUserSearch
  | OnToggleCircleCreation
  | OnTimerCreateRandomCircle
  | OnWindowSizeChange Size
  | SnakeMessage SnakeGame.Msg

mapSnakeMsg : SnakeGame.Msg -> Msg
mapSnakeMsg msg =
  SnakeMessage msg
