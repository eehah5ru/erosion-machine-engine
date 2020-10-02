module Timeline.Types exposing (..)

import List
import Maybe exposing (withDefault)
-- type alias HasId a =
--     {a | id : String}

-- type alias HasLabel a =
--     { a | label : String }

-- type alias HasClass a =
--     { a | class : String }

-- type alias HasDuration a =
--     { a | duration : Int }


type alias VideoData
    = { id : String
      , label : String
      , class : String
      , duration : Int
      , urlMP4 : String
      , subtitlesRu : String
      , subtitlesEn : String
      , loop : Bool
      , delayed : Int
      }

type alias ImageData =
    { id : String
    , label : String
    , class : String
    , duration : Int
    , src : String
    , delayed : Int
    }

type alias TextData =
    { id : String
    , label : String
    , class : String
    , duration : Int
    , text : String
    , delayed : Int
    }

type alias AddClassData =
    { id : String
    , label : String
    , class : String
    , delayed : Int
    }

type alias AssemblageData =
    { label : String
    , events : List Event
    }

type Event
    = ShowVideo VideoData
    | ShowImage ImageData
    | ShowText TextData
    | AddClass AddClassData
    | Assemblage AssemblageData

-- type alias Event =
--     { eventType : String
--     , label : String
--     }

type alias TimelineConfig =
    { delay : Int
    , disabled : Bool
    }

type alias Timeline =
    { config : TimelineConfig
    , events: List Event
    }

---
--- utils
---


getLabel : Event -> String
getLabel e =
    case e of
        (ShowVideo vd) -> vd.label
        (ShowImage id) -> id.label
        (ShowText td) -> td.label
        (AddClass acd) -> acd.label
        (Assemblage ad) -> ad.label


getDuration : Event -> Maybe Int
getDuration e =
    case e of
        (ShowVideo vd) -> Just vd.duration
        (ShowImage id) -> Just id.duration
        (ShowText td) -> Just td.duration
        (AddClass acd) -> Nothing
        (Assemblage ad) -> Just <| List.sum <| List.map (withDefault 0) <| List.map getDuration ad.events

getType : Event -> String
getType e =
    case e of
        (ShowVideo vd) -> "show_video"
        (ShowImage id) -> "show_image"
        (ShowText td) -> "show_text"
        (AddClass acd) -> "add_class"
        (Assemblage ad) -> "assemblage"

getId : Event -> String
getId e =
    case e of
        (ShowVideo vd) -> vd.id
        (ShowImage id) -> id.id
        (ShowText td) -> td.id
        (AddClass acd) -> acd.id
        (Assemblage ad) -> ad.label


-- type alias G1 = { name : String }

-- type alias G2 = { name : String }

-- type alias Person a =
--     { a | name : String }

-- getName : Person a -> String
-- getName p = p.name

-- g1 : G1
-- g1 = { name = "g1"}

-- g2 : G2
-- g2 = { name = "g2"}
