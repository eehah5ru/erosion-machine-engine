module ErosionMachine.ErosionMachine exposing (..)

import List as L
import Random
import Process
import Task
import Time
import Json.Decode as D
import Uuid

import Types exposing (..)
import Timeline.Types exposing (..)
import ErosionMachine.Ports exposing (..)

--
-- cmd helpers
--



selectErosion : Timeline -> Result String (Cmd Msg)
selectErosion timeline =
    case Maybe.map2 Tuple.pair (L.head timeline.events) (Just timeline.events) of
        Nothing -> (Err "empty events list")
        Just (e, es) -> Ok <| Random.generate Erode <| Random.map2 Tuple.pair (Random.uniform e es) (Uuid.uuidGenerator)


waitTillTheEndOfEvent : Event -> Uuid.Uuid -> Cmd Msg
waitTillTheEndOfEvent e frameId =
    case (getDuration e) of
        Nothing -> Cmd.none
        Just dur -> Process.sleep (toFloat dur) |> Task.perform (always (SelectNextErosion frameId))

handleUserInput : Model -> Cmd Msg
handleUserInput m =
    case m of
        Showing {showed} ->
            rollBack showed
        _ -> Cmd.none

handleTimeTick : Model -> (Model, Cmd Msg)
handleTimeTick m =
    case m of
        Waiting {counter, timeline} ->
            if counter > 5 then
                case selectErosion timeline of
                    Err s -> (Error s, Cmd.none)
                    Ok cmd -> (tick m, cmd)
            else
                (tick m, Cmd.none)
        _ -> (m, Cmd.none)

handleSelectNextErosion : Model -> Uuid.Uuid -> (Model, Cmd Msg)
handleSelectNextErosion model sourceFrameId =
    case model of
        Showing {timeline, frameId} ->
            if frameId /= sourceFrameId then
                (model, Cmd.none)
            else
                case selectErosion timeline of
                    Err s -> (Error s, Cmd.none)
                    Ok cmd -> (model, cmd)

        _ -> (model, Cmd.none)

--
-- port helpers
--
jsErode : Event -> Cmd Msg
jsErode e =
    case e of
        ShowVideo vd -> jsShowVideo vd
        ShowImage id -> jsShowImage id
        ShowText td -> jsShowText td
        AddClass acd -> jsAddClass acd
        -- FIXME: replace with actual logic
        Assemblage ad -> jsShowAssemblage ad.label

rollBack : List Event -> Cmd Msg
rollBack showed =
    jsRollBack <| List.map getId showed

--
--
-- model helpers
--
--

showEvent : Model -> Event -> Uuid.Uuid -> Model
showEvent m e fId =
    case m of
        Waiting {timeline} ->
            Showing { timeline = timeline
                    , showed = [e]
                    , event = e
                    , frameId = fId}
        Showing {showed, timeline} ->
            Showing { timeline = timeline
                    -- FIXME - add class should not be added to the list of rolled back elements
                    , showed = e :: showed
                    , event = e
                    , frameId = fId}
        _ -> Error "Cannot show event from this state"

--
-- wait till the user becomes calm
--
wait : Model -> Model
wait m =
    case m of
        Showing{timeline} ->
            Waiting { timeline = timeline
                    , counter = 0}
        Waiting{timeline} ->
            Waiting { timeline = timeline
                    , counter = 0}
        _ -> Error "Cannot wait from this state"

tick : Model -> Model
tick m =
    case m of
        Showing _ -> m
        Waiting {timeline, counter} ->
            Waiting { timeline = timeline
                    , counter = counter + 1}
        _ -> m
