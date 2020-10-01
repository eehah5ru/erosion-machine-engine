module Types exposing (..)
import Http

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
    , event : Event }

-- UPDATE
type Msg
  = LoadTimeline
  | GotTimeline (Result Http.Error Timeline)
  | SelectNextErosion
  | Erode Event
  | UserInput
  | TimeTick
  | RaiseError String
