module InfScroll exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json
import Task
import Process

type alias Pos =
  { scrolledHeight : Int
  , contentHeight : Int
  , containerHeight : Int
  }

type Msg = Scroll Pos

type Config model item msg
    = Config { loadMore : model -> msg
      , msgWrapper : Msg -> msg
      , itemView : item -> Html msg
      }

update : Config model item msg -> model -> Msg -> (model, Cmd msg)
update (Config cfg) model msg =
    case msg of
        Scroll pos ->
          let
            bottom = toFloat <| pos.scrolledHeight + pos.containerHeight
            threashold = toFloat pos.contentHeight - (toFloat pos.containerHeight * 0.2)
            shouldLoadMore = bottom > threashold
          in
            if shouldLoadMore then
              (model, performMessage <| cfg.loadMore model )
            else
              (model, Cmd.none)

view : Config model item msg -> List item -> Html msg
view (Config cfg) items =
  div [ class "inf-scroll-container", onScroll (cfg.msgWrapper << Scroll) ]
    (List.map cfg.itemView items)

unreachable =
    (\_ -> Debug.crash "This failure cannot happen.")

performMessage : msg -> Cmd msg
performMessage msg =
    Task.perform unreachable identity (Task.succeed msg)

onScroll : (Pos -> action) -> Attribute action
onScroll tagger =
  on "scroll" (Json.map tagger decodeScrollPosition)

decodeScrollPosition : Json.Decoder Pos
decodeScrollPosition =
  Json.object3 Pos
    scrollTop
    scrollHeight
    (maxInt offsetHeight clientHeight)

scrollTop : Json.Decoder Int
scrollTop =
  Json.at [ "target", "scrollTop" ] Json.int

scrollHeight : Json.Decoder Int
scrollHeight =
  Json.at [ "target", "scrollHeight" ] Json.int

offsetHeight : Json.Decoder Int
offsetHeight =
  Json.at [ "target", "offsetHeight" ] Json.int

clientHeight : Json.Decoder Int
clientHeight =
  Json.at [ "target", "clientHeight" ] Json.int

maxInt : Json.Decoder Int -> Json.Decoder Int -> Json.Decoder Int
maxInt x y =
  Json.object2 Basics.max x y