module Main exposing (..)

import Html exposing (..)
import Html.App exposing (..)
import Html.Attributes exposing (..)
import InfScroll

type alias Model =
    { reached : Int
    }

type Msg = LoadMore Int | InfS InfScroll.Msg

main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }

init =
    ( { reached = 30 }, Cmd.none )

update msg model =
    case msg of
        LoadMore n ->
          if n == model.reached then
            ( { model | reached = model.reached + 10 }, Cmd.none )
          else
            (model, Cmd.none)
        InfS msg ->
          InfScroll.update cfg model msg

view model =
  let
    items = [1..model.reached]
  in
    div []
      [ stylesheet
      , h1 []
          [ text ("Showing " ++ (toString model.reached) ++ " numbers")
          ]
      , div [ id "wrapper" ] [
          InfScroll.view cfg items
        ]
      ]

itemView n = div [] [ text <| " -- " ++ (toString n) ++ " -- " ]

cfg : InfScroll.Config Model Int Msg
cfg = InfScroll.Config
    { loadMore = \ m -> LoadMore m.reached
    , msgWrapper = InfS
    , itemView = itemView
    }

stylesheet =
    let
        attrs =
            [ attribute "rel"       "stylesheet"
            , attribute "property"  "stylesheet"
            , attribute "href"      "/nats.css"
            ]
    in
        node "link" attrs []
