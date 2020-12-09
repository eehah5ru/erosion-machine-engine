module ErosionMachine.ErosionMachine exposing (..)

import List as L
import Random
import Random.List exposing (shuffle)
import Process
import Task
import Time
import Json.Decode as D
import Uuid
import Result

import Types exposing (..)
import Timeline.Types exposing (..)
import ErosionMachine.Ports exposing (..)


--
--
-- cmd helpers
--
--

--
-- shufle timeline utils
--

type ShuffledEvent = SingleEvent Event
                   | ListOfEvents (List Event)

shuffleEvent : Event -> Random.Generator (ShuffledEvent)
shuffleEvent e =
    case e of
        Chapter cd -> Random.map ListOfEvents (shuffle cd.events)
        _ -> Random.map SingleEvent (Random.constant e)

foldEventGenerators : Random.Generator ShuffledEvent -> Random.Generator (List Event) -> Random.Generator (List Event)
foldEventGenerators rEv rEvs =
    Random.map2 (\ ev evs ->
                case ev of
                    SingleEvent e -> e :: evs
                    ListOfEvents es -> List.concat [es, evs]) rEv rEvs


deepShuffle : List Event -> Random.Generator (List Event)
deepShuffle events =
    List.foldl foldEventGenerators (Random.constant []) <| List.map shuffleEvent events

--
-- args: timeline and muted status
--
selectErosion : Timeline -> Bool -> Cmd Msg
selectErosion timeline isMuted =
    Random.generate PlanErosion <| Random.map2 Tuple.pair (Random.andThen deepShuffle <| shuffle <| List.map (\ e -> setIsMuted isMuted e) timeline.events) (Uuid.uuidGenerator)

--
-- wait till the end of timeline and re-schedule shuffled timeline events
-- asking js about autoplay status before
--
waitTillTheEndOfFrame : Int -> Uuid.Uuid -> Cmd Msg
waitTillTheEndOfFrame delay frameId =
    Process.sleep (toFloat delay) |> Task.perform (always (CheckAutoplayStatus frameId))

handleUserInput : ErosionModel -> (ErosionModel, Cmd Msg)
handleUserInput m =
    case m of
        Showing {events, timeline} ->
            let cmd = rollBack <| (timeline.config.finalErosion :: (List.map (\x -> x.event) events))
            in
                (wait m, cmd)
        Paused {events, timeline} ->
            let cmd = rollBack <| (timeline.config.finalErosion :: (List.map (\x -> x.event) events))
            in
                (wait m, cmd)
        _ -> (m, Cmd.none)

handleTimeTick : ErosionModel -> (ErosionModel, Cmd Msg)
handleTimeTick m =
    case m of
        Waiting {counter, timeline} ->
            if counter > 5 then
                (WaitingForAutoplayStatus {timeline = timeline}, jsCheckAutoplayStatus {})
            else
                (tick m, Cmd.none)
        _ -> (m, Cmd.none)

-- handleSelectNextErosion : ErosionModel -> Uuid.Uuid -> (ErosionModel, Cmd Msg)
-- handleSelectNextErosion model sourceFrameId =
--     case model of
--         Showing {timeline, frameId} ->
--             if frameId /= sourceFrameId then
--                 (model, Cmd.none)
--             else
--                 (model, selectErosion timeline)
--         _ -> (model, Cmd.none)

handlePlanErosion : List Event -> Uuid.Uuid -> ErosionModel -> Result String (ErosionModel, Cmd Msg)
handlePlanErosion events frameId model =
    case model of
        Paused _ -> Ok (model, Cmd.none)
        _ -> let (frameDuration, erodeEvents) = toErodeEvents 0 events
             in
                 Result.map (\m -> (m, Cmd.batch [planErosion erodeEvents frameId, waitTillTheEndOfFrame frameDuration frameId])) (showEvents model erodeEvents frameId)

--
-- schedule erosion events from the timeline
--
planErosion : List ErodeEvent -> Uuid.Uuid -> Cmd Msg
planErosion events frameId =
    let mkCmd = \e ->
                Process.sleep (toFloat e.startAt) |> Task.perform (always (Erode e.event frameId))
        cmds = List.map mkCmd events
    in
        Cmd.batch cmds


handleErode : Event -> Uuid.Uuid -> ErosionModel -> (ErosionModel, Cmd Msg)
handleErode event currentFrameId model =
    case model of
        Showing {frameId} ->
            if currentFrameId /= frameId then
                (model, Cmd.none)
            else
                (model, jsErode event frameId)
        _ -> (model, Cmd.none)


handlePauseTimeline : ErosionModel -> (ErosionModel, Cmd Msg)
handlePauseTimeline model =
    case model of
        Showing data ->
            (Paused data, jsErode (setIsMuted data.isMuted data.timeline.config.finalErosion) data.frameId)
        _ -> (model, Cmd.none)

handleCheckAutoplayStatus : Uuid.Uuid -> ErosionModel -> (ErosionModel, Cmd Msg)
handleCheckAutoplayStatus sourceFrameId model =
    case model of
        Showing {timeline, frameId} ->
            if frameId /= sourceFrameId then
                (model, Cmd.none)
            else
                (WaitingForAutoplayStatus {timeline = timeline}, jsCheckAutoplayStatus {})
        _ -> (model, Cmd.none)


handleSetAutoplayStatus : Bool -> ErosionModel -> (ErosionModel, Cmd Msg)
handleSetAutoplayStatus isMuted model =
    case model of
        WaitingForAutoplayStatus {timeline} ->
            ( WaitingForErosion {timeline = timeline, isMuted = isMuted}
            , selectErosion timeline isMuted )
        _ -> (model, Cmd.none)
--
-- port helpers
--
jsErode : Event -> Uuid.Uuid -> Cmd Msg
jsErode e frameId =
    case e of
        ShowVideo vd -> jsShowVideo {vd | id = vd.id ++ "-" ++ (Uuid.toString frameId)}
        ShowImage iData -> jsShowImage {iData | id = iData.id ++ "-" ++ (Uuid.toString frameId)}
        ShowText td -> jsShowText {td | id = td.id ++ "-" ++ (Uuid.toString frameId)}
        AddClass acd -> jsAddClass {acd | id = acd.id ++ "-" ++ (Uuid.toString frameId)}
        RemoveClass rcd -> jsRemoveClass {rcd | id = rcd.id ++ "-" ++(Uuid.toString frameId)}
        HideElement hed -> jsHideElement hed
        Assemblage _ -> Cmd.none
        Chapter cs -> Cmd.none

rollBack : List Event -> Cmd Msg
rollBack shownEvents =
    let f e =
            case e of
                ShowVideo vd -> jsRollBackShowVideo vd
                ShowImage id -> jsRollBackShowImage id
                ShowText td -> jsRollBackShowText td
                AddClass acd -> jsRollBackAddClass acd
                RemoveClass rcd -> jsRollBackRemoveClass rcd
                HideElement hed -> jsRollBackHideElement hed
                _ -> Cmd.none
    in
        Cmd.batch
            <| List.map f shownEvents

--
--
-- model helpers
--
--

showEvents : ErosionModel -> List ErodeEvent -> Uuid.Uuid -> Result String ErosionModel
showEvents m events fId =
    case m of
        Waiting {timeline} ->
            Showing { timeline = timeline
                    , events = events
                    , frameId = fId
                    , isMuted = True} |> Ok
        Showing {timeline, isMuted} ->
            Showing { timeline = timeline
                    , events = events
                    , frameId = fId
                    , isMuted = isMuted} |> Ok
        WaitingForErosion {timeline, isMuted} ->
            Showing { timeline = timeline
                    , events = events
                    , frameId = fId
                    , isMuted = isMuted} |> Ok
        _ -> Err "Cannot show event from this state"

--
-- wait till the user becomes calm
--
wait : ErosionModel -> ErosionModel
wait m =
    case m of
        Showing{timeline} ->
            Waiting { timeline = timeline
                    , counter = 0}
        Paused {timeline} ->
            Waiting { timeline = timeline
                    , counter = 0 }
        Waiting{timeline} ->
            Waiting { timeline = timeline
                    , counter = 0}
        _ -> m -- Error "Cannot wait from this state"

tick : ErosionModel -> ErosionModel
tick m =
    case m of
        Showing _ -> m
        Waiting {timeline, counter} ->
            Waiting { timeline = timeline
                    , counter = counter + 1}
        _ -> m
