module Main exposing (..)
-- Press a button to send a GET request for random cat GIFs.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/json.html
--

import Browser
import Browser.Events as Events
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
import Time

import Types exposing (..)
import Timeline.Decoder exposing (..)
import Timeline.Types exposing (..)
import Timeline.View
-- import Index.View
import ErosionMachine.ErosionMachine exposing (..)

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
  (LoadingTimeline, getTimeline)


-- randomEvent : List Event -> Random.Generator (Maybe Event)
-- randomEvent es = Random.uniform (L.head es) (L.map (\x -> Just x) es)

-- changeRandomEvent : Timeline -> Event -> Cmd Msg
-- changeRandomEvent tl e =
--     case (getDuration e) of
--         Nothing -> Cmd.none
--         Just dur -> Process.sleep (toFloat dur) |> Task.perform (always (FireRandomEvent tl))

-- showEvent : Timeline -> Maybe Event -> Cmd Msg
-- showEvent tl e =
--     Cmd.batch [ Task.perform (always (ShowEmptyPage tl)) (Task.succeed ())
--               , Task.perform (always (ShowEvent tl e)) (Process.sleep 100)]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    --
    -- loading timeline
    --
    LoadTimeline ->
      (LoadingTimeline, getTimeline)

    GotTimeline result ->
      case result of
        Ok timeline ->
          (Waiting {timeline = timeline, counter = 0}, Cmd.none)
        Err s ->
          (ErrorLoadTimeline s, Cmd.none)

    --
    -- selecting erosion
    --
    SelectNextErosion ->
        handleSelectNextErosion model
    --
    -- eroding
    --
    Erode e ->
        (showEvent model e, Cmd.batch [jsErode e, waitTillTheEndOfEvent e])

    UserInput ->
        (wait model, handleUserInput model)
    TimeTick ->
        handleTimeTick model
    RaiseError s ->
        (Error s, Cmd.none)
    -- RandomEventFired tl mE ->
    --     case mE of
    --         Nothing -> (Error "error getting random event" tl, Cmd.none)
    --         Just e -> ( ViewEvent tl Nothing
    --                   , (Process.sleep 100 |> Task.perform (always (ShowEvent tl e))))
    -- ShowEvent tl e -> (ViewEvent tl (Just e), changeRandomEvent tl e)



userInputSub : (D.Decoder Msg -> Sub Msg) -> Sub Msg
userInputSub f =
    f (D.succeed UserInput)

userInputSubs : List (Sub Msg)
userInputSubs =
    [userInputSub Events.onClick
    , userInputSub Events.onMouseMove
    , userInputSub Events.onKeyUp]

timerSub : Sub Msg
timerSub =
    Time.every 1000 (always TimeTick)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Showing _ ->
            Sub.batch userInputSubs
        _ -> Sub.batch <| timerSub :: userInputSubs



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

    LoadingTimeline ->
      text "Loading timeline..."

    Waiting {counter} ->
        text ("waiting " ++ (String.fromInt counter))

    Showing {event} ->
        text <| "showing " ++ (getLabel event)

    Error msg ->
        text <| "ERROR: " ++ msg
