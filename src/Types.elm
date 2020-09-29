module Types exposing (..)
import Http

import Timeline.Types exposing (..)

-- MODEL
type Model
  = ErrorLoadTimeline Http.Error
  | Loading
  | Success Timeline
  | Error String Timeline
  | ViewEvent Timeline (Maybe Event)


-- UPDATE
type Msg
  = LoadTimeline
  | GotTimeline (Result Http.Error Timeline)
  | FireRandomEvent Timeline
  | RandomEventFired Timeline (Maybe Event)
  | ShowEvent Timeline Event
