module Main exposing (..)
-- Press a button to send a GET request for random cat GIFs.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/json.html
--

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (viewMaybe)
import Http
import Json.Decode as D exposing (Decoder, field, string, int, bool, map2, list)
import Json.Decode.Extra as DE
import List as L
import Random
import Process
import Task

import Types exposing (..)
import Timeline.Decoder exposing (..)
import Timeline.Types exposing (..)
import Timeline.View
import Index.View

-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- type Event
--     = Video String
--     | Text String
--     | Image String

init : () -> (Model, Cmd Msg)
init _ =
  (Loading, getTimeline)


randomEvent : List Event -> Random.Generator (Maybe Event)
randomEvent es = Random.uniform (L.head es) (L.map (\x -> Just x) es)

changeRandomEvent : Timeline -> Event -> Cmd Msg
changeRandomEvent tl e =
    case (getDuration e) of
        Nothing -> Cmd.none
        Just dur -> Process.sleep (toFloat dur) |> Task.perform (always (FireRandomEvent tl))

-- showEvent : Timeline -> Maybe Event -> Cmd Msg
-- showEvent tl e =
--     Cmd.batch [ Task.perform (always (ShowEmptyPage tl)) (Task.succeed ())
--               , Task.perform (always (ShowEvent tl e)) (Process.sleep 100)]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LoadTimeline ->
      (Loading, getTimeline)

    GotTimeline result ->
      case result of
        Ok url ->
          (Success url, Cmd.none)

        Err s ->
          (ErrorLoadTimeline s, Cmd.none)
    FireRandomEvent tl ->
        ( model
        , Random.generate (RandomEventFired tl) (randomEvent tl.events)
        )
    RandomEventFired tl mE ->
        case mE of
            Nothing -> (Error "error getting random event" tl, Cmd.none)
            Just e -> ( ViewEvent tl Nothing
                      , (Process.sleep 100 |> Task.perform (always (ShowEvent tl e))))
    ShowEvent tl e -> (ViewEvent tl (Just e), changeRandomEvent tl e)



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ h2 [] [ text "Load" ]
    , viewTimeline model
    ]


viewTimeline : Model -> Html Msg
viewTimeline model =
  case model of
    ErrorLoadTimeline s ->
      div []
        [ text "error loading timeline"
        , button [ onClick LoadTimeline ] [ text "Try Again!" ]
        ]

    Loading ->
      text "Loading..."

    Success timeline ->
        Index.View.render timeline
    Error err tl ->
        div []
            [ h1 [] [text err]
            , Index.View.buttonFireRandomEvent tl]
    ViewEvent timeline mE ->
        div []
            [
             Index.View.buttonFireRandomEvent timeline
            , viewMaybe Timeline.View.renderEvent mE]



-- HTTP


getTimeline : Cmd Msg
getTimeline =
  Http.get
    { url = "https://dev.eeefff.org/data/outsourcing-paradise-parasite/erosion-machine-timeline.json"
    , expect = Http.expectJson GotTimeline timelineDecoder
    }
