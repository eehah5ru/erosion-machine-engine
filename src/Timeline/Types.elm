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
      , muted : Bool
      , position : String
      }

type alias ImageData =
    { id : String
    , label : String
    , class : String
    , duration : Int
    , src : String
    , delayed : Int
    , position : String
    }

type alias TextData =
    { id : String
    , label : String
    , class : String
    , duration : Int
    , text : String
    , delayed : Int
    , position : String
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

type alias ChapterData =
    { label : String
    , events : List Event
    }

type alias HideElementData =
    { label : String
    , id : String
    , delayed : Int
    }


type Event
    = ShowVideo VideoData
    | ShowImage ImageData
    | ShowText TextData
    | AddClass AddClassData
    | HideElement HideElementData
    | Assemblage AssemblageData
    | Chapter ChapterData

-- type alias Event =
--     { eventType : String
--     , label : String
--     }

type alias SplashScreenText =
    { ru : List String
    , en : List String}

type alias TimelineConfig =
    { delay : Int
    , disabled : Bool
    , finalErosion : Event
    , splashScreenText : SplashScreenText
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
        (HideElement hed) -> hed.label
        (Assemblage ad) -> ad.label
        (Chapter cd) -> cd.label

getDelay : Event -> Int
getDelay e =
    case e of
        (ShowVideo vd) -> vd.delayed
        (ShowImage id) -> id.delayed
        (ShowText td) -> td.delayed
        (AddClass acd) -> acd.delayed
        (HideElement hed) -> hed.delayed
        (Assemblage ad) -> 0
        (Chapter _) -> 0

getAssemblageDuration : AssemblageData -> Int
getAssemblageDuration ad =
    let durs = List.map (withDefault 0) <| List.map getDuration ad.events
        dels = List.map getDelay ad.events
    in
        withDefault 0 <| List.maximum <| List.map2 (+) durs dels

getChapterDuration : ChapterData -> Int
getChapterDuration cd =
    List.sum <| List.map (withDefault 0) <| List.map getDuration cd.events

getDuration : Event -> Maybe Int
getDuration e =
    case e of
        (ShowVideo vd) -> Just vd.duration
        (ShowImage id) -> Just id.duration
        (ShowText td) -> Just td.duration
        (AddClass acd) -> Nothing
        (HideElement _) -> Nothing
        (Assemblage ad) -> Just <| getAssemblageDuration ad
        (Chapter cd) -> Just <| getChapterDuration cd

getType : Event -> String
getType e =
    case e of
        (ShowVideo vd) -> "show_video"
        (ShowImage id) -> "show_image"
        (ShowText td) -> "show_text"
        (AddClass acd) -> "add_class"
        (HideElement _) -> "hide_element"
        (Assemblage ad) -> "assemblage"
        (Chapter _) -> "chapter"

getId : Event -> String
getId e =
    case e of
        (ShowVideo vd) -> vd.id
        (ShowImage id) -> id.id
        (ShowText td) -> td.id
        (AddClass acd) -> acd.id
        (HideElement hed) -> hed.label
        (Assemblage ad) -> ad.label
        (Chapter cd) -> cd.label

setIsMuted : Bool -> Event -> Event
setIsMuted isMuted e =
    case e of
        (ShowVideo vd) -> ShowVideo {vd | muted = isMuted}
        (Assemblage ad) -> Assemblage {ad | events = List.map (setIsMuted isMuted) ad.events}
        (Chapter cd) -> Chapter {cd | events = List.map (setIsMuted isMuted) cd.events}
        _ -> e
