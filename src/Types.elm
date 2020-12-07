module Types exposing (..)
import Http
import Uuid
import Timeline.Types exposing (..)
import Tuple.Extra as TE
import Monocle.Lens exposing (Lens)
import Monocle.Optional exposing (Optional)


import SplashScreen.Types exposing (..)

type Model
    = ErrorLoadTimeline Http.Error
    | LoadingTimeline
    | Error String
    | Running
      { erosionModel : ErosionModel
      , splashScreenModel : SplashScreenModel }


-- MODEL
type ErosionModel
    = Waiting { timeline : Timeline
              , counter : Int }
    | WaitingForAutoplayStatus
      { timeline : Timeline}
    | WaitingForErosion
      { timeline : Timeline
      , isMuted : Bool}
    -- showing events
    | Showing
      { timeline : Timeline
      , events : List ErodeEvent
      , frameId : Uuid.Uuid
      , isMuted : Bool}
    | Paused
      { timeline : Timeline
      , events : List ErodeEvent
      , frameId : Uuid.Uuid
      , isMuted : Bool}

--
--
-- model helpers
--
--

l_erosionModel : Optional Model ErosionModel
l_erosionModel =
    let get m = case m of
                    Running d -> Just d.erosionModel
                    _ -> Nothing
        set v m = case m of
                      Running d -> Running {d | erosionModel = v}
                      _ -> m
    in
        Optional get set

l_splashScreenModel : Optional Model SplashScreenModel
l_splashScreenModel =
    let get m = case m of
                    Running d -> Just d.splashScreenModel
                    _ -> Nothing
        set v m = case m of
                      Running d -> Running {d | splashScreenModel = v}
                      _ -> m
    in
        Optional get set

-- onRunning : Optional Model m
--           -> (m -> a)
--           -> Model
--           -> Maybe a
-- onRunning lens handler model =

--     case model of
--         Running _ ->
--             Just <| handler (getModel model)
--         _ -> Nothing



-- setErosionModel : Model -> ErosionModel -> Model
-- setErosionModel model v =
--     case model of
--         Running d -> Running {d | erosionModel = v}
--         _ -> model

-- setSplashScreenModel : Model -> SplashScreenModel -> Model
-- setSplashScreenModel model v =
--     case model of
--         Running d -> Running {d | splashScreenModel = v}
--         _ -> model


handleSubModel : Optional Model m
                -> Model
                -> (m -> (m, Cmd Msg))
                -> (Model, Cmd Msg)
handleSubModel lens model handler =
    Maybe.withDefault (model, Cmd.none)
        <| Maybe.map (\ (m, cs) -> (lens.set m model, cs))
        <| Maybe.andThen (\ m -> handler m |> Just)
        <| lens.getOption model

handleSubModelResult : Optional Model m
                     -> Model
                     -> (m -> Result s (m, Cmd Msg))
                     -> Result s (Model, Cmd Msg)
handleSubModelResult lens model handler =
    case lens.getOption model of
        Just m -> handler m |> Result.map (\ (r, cs) -> (lens.set r model, cs))
        Nothing -> Ok (model, Cmd.none)

-- UPDATE messages
type Msg
  = GotTimeline (Result Http.Error Timeline)
  | PlanErosion (List Event, Uuid.Uuid)
  | Erode Event Uuid.Uuid
  | UserInput
  | TimeTick
  | PauseTimeline
  | CheckAutoplayStatus Uuid.Uuid
  | SetAutoplayStatus Bool
  | RaiseError String
  -- splash screen messages
  | SplashScreenClosed
  | SplashScreenIsShown
  | GrowSplashScreen
  | SplashScreenGotLanguage Lang

--
-- AUX TYPES
--
type alias ErodeEvent
    = { event : Event
      , startAt : Int
      , endAt : Int }

toErodeEvents : Int -> List Event -> (Int, List ErodeEvent)
toErodeEvents offset events =
    let f = \e r ->
            let (startOffset, ees) = r
                (endOffset, ee) = toErodeEvent startOffset e
            in
                (endOffset, (List.append ees ee))
    in
        List.foldl f (offset, []) events


toErodeEvent : Int -> Event -> (Int, List ErodeEvent)
toErodeEvent offset event =
    case event of
        Assemblage ad ->
            let dur = Maybe.withDefault 0 <| getDuration event
                mkF = \e -> ErodeEvent e (offset + (getDelay e)) (offset + (getDelay e) + (Maybe.withDefault 0 <| getDuration e))
                erodeEvents = List.map mkF ad.events
            in
                (offset + dur, erodeEvents)
        _ ->
            let dur = Maybe.withDefault 0 <| getDuration event
                erodeEvent = ErodeEvent event offset (offset + dur)
            in
                (erodeEvent.endAt, [erodeEvent])
