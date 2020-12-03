module Types exposing (..)
import Http
import Uuid
import Timeline.Types exposing (..)
import Tuple.Extra as TE

-- MODEL
type Model
  = ErrorLoadTimeline Http.Error
  | LoadingTimeline
  | Waiting { timeline : Timeline
             , counter : Int }
  | Error String
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

-- UPDATE
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
  | SplashScreenClosed

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
