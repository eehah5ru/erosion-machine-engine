module Types exposing (..)
import Http
import Uuid
import Timeline.Types exposing (..)

-- MODEL
type Model
  = ErrorLoadTimeline Http.Error
  | LoadingTimeline
  | Waiting { timeline : Timeline
             , counter : Int }
  | Error String
  -- showing events
  | Showing
    { timeline : Timeline
    , showed : List Event
    , event : Event
    , frameId : Uuid.Uuid}

-- UPDATE
type Msg
  = LoadTimeline
  | GotTimeline (Result Http.Error Timeline)
  | SelectNextErosion Uuid.Uuid
  | Erode (Event, Uuid.Uuid)
  | UserInput
  | TimeTick
  | RaiseError String
