module Challenges.Challenge4 exposing (..)

import Challenges.Common.Common exposing (backBtn, dropDuplicates)
import Html exposing (Html, div, text, input, form, img, p, ul, li)
import Html.Attributes exposing (class, placeholder, src)
import Html.Events exposing (onInput)
import Models exposing (Model, GithubUser)
import Msgs exposing (Msg)
import RemoteData exposing (WebData)

view : Model -> Html Msg
view model =
  div [ class "container-fluid" ]
    [ backBtn
    , div [ class "row userInputForm" ]
        [ div [ class "col-sm-2" ] []
        , div [ class "col-sm-8" ] [ userNameInput ]
        , div [ class "col-sm-2" ] [] ]
    , div [ class "row" ]
      [ div [ class "col-sm-2" ] []
      , div [ class "col-sm-4"]
        [ githubUserImage model.githubUser ]
      , div [ class "col-sm-4"]
        [ githubUserDetails model.githubUser model.githubUserLanguages ]
      , div [ class "col-sm-2" ] []
      ]
    ]

userNameInput : Html Msg
userNameInput =
  form []
    [ div [ class "form-group" ]
        [ input
            [ class "form-control"
            , placeholder "Enter a github user name here..."
            , onInput Msgs.OnChangeGithubUserNameToSearch ] []
        ]
    ]

githubUserImage : WebData GithubUser -> Html msg
githubUserImage maybeUserInfo =
  case maybeUserInfo of
    RemoteData.Success userInfo ->
      div []
        [ img [ src userInfo.avatarUrl, class "img-rounded userImg" ] [] ]
    RemoteData.NotAsked -> div [] []
    RemoteData.Loading -> div [] []
    RemoteData.Failure err -> div [] []

githubUserDetails : WebData GithubUser -> WebData (List (Maybe String)) -> Html msg
githubUserDetails maybeUserInfo maybeUserLanguages =
  div [ class "userDetails" ]
    [ githubUserName maybeUserInfo
    , githubUserLanguages maybeUserLanguages
    ]

githubUserName : WebData GithubUser -> Html msg
githubUserName maybeUserInfo =
  case maybeUserInfo of
    RemoteData.Success userInfo ->
      div []
        [ p [ class "h3" ] [ text "Name:" ]
        , text userInfo.name
        ]
    RemoteData.NotAsked -> div [] []
    RemoteData.Loading -> div [] []
    RemoteData.Failure err -> div [] []

githubUserLanguages : WebData (List (Maybe String)) -> Html msg
githubUserLanguages maybeLanguages =
  case maybeLanguages of
    RemoteData.Success languages ->
      div []
        [ p [ class "h3" ] [ text "Languages:" ]
        , ul []
          ( languages
            |> List.filterMap identity
            |> dropDuplicates
            |> List.map (\l -> li [] [ text l ])
          )
        ]
    RemoteData.NotAsked -> div [] []
    RemoteData.Loading -> div [] []
    RemoteData.Failure err -> div [] []
