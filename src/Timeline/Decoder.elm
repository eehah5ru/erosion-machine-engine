module Timeline.Decoder exposing (..)

import Json.Decode as D exposing (Decoder, field, string, int, bool, map2, list)
import Json.Decode.Extra as DE
import List as L
import Http


import Types exposing (..)
import Timeline.Types exposing (..)

--
-- timeline decoders
--

timelineConfigDecoder : Decoder TimelineConfig
timelineConfigDecoder =
    D.map2 TimelineConfig (D.at ["config", "delay"] int) (D.at ["config", "disabled"] bool)

event : String -> Decoder Event -> Decoder Event
event label eDecoder = DE.when (field "type" string) (\x -> x == label) eDecoder

fromData : (a -> Event) -> Decoder a -> Decoder Event
fromData f d = d |> D.andThen (\x -> D.succeed (f x))

assemblageDecoder : Decoder Event
assemblageDecoder =
    (D.map2 AssemblageData (field "label" string) (field "events" (D.list (D.lazy (\_ -> eventDecoder))))) |> fromData Assemblage

eventDecoder : Decoder Event
eventDecoder = D.oneOf [ event "assemblage" assemblageDecoder
                        , event "showVideo" showVideoDecoder
                        , event "showImage" showImageDecoder
                        , event "showText" showTextDecoder
                        , event "addClass" addClassDecoder]

eventsDecoder : Decoder (List Event)
eventsDecoder =
    field "timeline" (D.list eventDecoder)

showVideoDecoder : Decoder Event
showVideoDecoder =
    D.map8 VideoData
        (field "id" string)
        (field "label" string)
        (field "class" string)
        (field "duration" int)
        (field "url_mp4" string)
        (field "subtitles_ru" string)
        (field "subtitles_en" string)
        (field "loop" bool |> DE.withDefault False) |> fromData ShowVideo

showImageDecoder : Decoder Event
showImageDecoder =
    D.map5 ImageData
        (field "id" string)
        (field "label" string)
        (field "class" string)
        (field "duration" int)
        (field "src" string) |> fromData ShowImage

showTextDecoder : Decoder Event
showTextDecoder =
    D.map5 TextData
        (field "id" string)
        (field "label" string)
        (field "class" string)
        (field "duration" int)
        (field "text" string) |> fromData ShowText

addClassDecoder : Decoder Event
addClassDecoder =
    D.map4 AddClassData
        (field "id" string)
        (field "label" string)
        (field "class" string)
        (field "delayed" int) |> fromData AddClass


timelineDecoder : Decoder Timeline
timelineDecoder =
  D.map2 Timeline timelineConfigDecoder eventsDecoder


--
--
-- HTTP
--
--

getTimeline : Cmd Msg
getTimeline =
  Http.get
    { url = "https://dev.eeefff.org/data/outsourcing-paradise-parasite/erosion-machine-timeline.json"
    , expect = Http.expectJson GotTimeline timelineDecoder
    }
