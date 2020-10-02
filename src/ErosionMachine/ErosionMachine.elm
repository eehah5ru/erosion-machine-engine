module ErosionMachine.ErosionMachine exposing (..)

import List as L
import Random
import Random.List exposing (shuffle)
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

selectErosion : Timeline -> Cmd Msg
selectErosion timeline =
    Random.generate PlanErosion <| Random.map2 Tuple.pair (shuffle timeline.events) (Uuid.uuidGenerator)

waitTillTheEndOfFrame : Int -> Uuid.Uuid -> Cmd Msg
waitTillTheEndOfFrame delay frameId =
    Process.sleep (toFloat delay) |> Task.perform (always (SelectNextErosion frameId))
handleUserInput : Model -> Cmd Msg
handleUserInput m =
    case m of
        Showing {events} ->
            rollBack <| List.map (\x -> x.event) events
        _ -> Cmd.none

handleTimeTick : Model -> (Model, Cmd Msg)
handleTimeTick m =
    case m of
        Waiting {counter, timeline} ->
            if counter > 5 then
                (tick m, selectErosion timeline)
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
                (model, selectErosion timeline)
        _ -> (model, Cmd.none)

handlePlanErosion : Model -> List Event -> Uuid.Uuid -> (Model, Cmd Msg)
handlePlanErosion model events frameId =
    let (frameDuration, erodeEvents) = toErodeEvents 0 events
    in
        (showEvents model erodeEvents frameId, Cmd.batch [planErosion erodeEvents frameId, waitTillTheEndOfFrame frameDuration frameId])

planErosion : List ErodeEvent -> Uuid.Uuid -> Cmd Msg
planErosion events frameId =
    let mkCmd = \e ->
                Process.sleep (toFloat e.startAt) |> Task.perform (always (Erode e.event frameId))
        cmds = List.map mkCmd events
    in
        Cmd.batch cmds


handleErode : Model -> Event -> Uuid.Uuid -> (Model, Cmd Msg)
handleErode model event currentFrameId =
    case model of
        Showing {frameId} ->
            if currentFrameId /= frameId then
                (model, Cmd.none)
            else
                (model, jsErode event)
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

showEvents : Model -> List ErodeEvent -> Uuid.Uuid -> Model
showEvents m events fId =
    case m of
        Waiting {timeline} ->
            Showing { timeline = timeline
                    , events = events
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
