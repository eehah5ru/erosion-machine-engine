module Timeline.Decoder exposing (..)

import Json.Decode as D exposing (Decoder, field, string, int, bool, map2, list)
import Json.Decode.Extra as DE
import Json.Decode.Pipeline exposing (required, optional)
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
    fromData ShowVideo <| (D.succeed VideoData
        |> required "id" string
        |> required "label" string
        |> required "class" string
        |> required "duration" int
        |> required "url_mp4" string
        |> required "subtitles_ru" string
        |> required "subtitles_en" string
        |> (optional "loop" bool False)
        |> (optional "delayed" int 0))

showImageDecoder : Decoder Event
showImageDecoder =
    fromData ShowImage <| (D.succeed ImageData
        |> required "id" string
        |> required "label" string
        |> required "class" string
        |> required "duration" int
        |> required "src" string
        |> optional "delayed" int 0)

showTextDecoder : Decoder Event
showTextDecoder =
    fromData ShowText
        <| (D.succeed TextData
                |> required "id" string
                |> required "label" string
                |> required "class" string
                |> required "duration" int
                |> required "text" string
                |> optional "delayed" int 0)

addClassDecoder : Decoder Event
addClassDecoder =
    fromData AddClass
        <| (D.succeed AddClassData
                   |> required "id" string
                   |> required "label" string
                   |> required "class" string
                   |> optional "delayed" int 0)


timelineDecoder : Decoder Timeline
timelineDecoder =
  D.map2 Timeline timelineConfigDecoder eventsDecoder


--
--
-- HTTP
--
--

getTimeline : String -> Cmd Msg
getTimeline timelineUrl =
  Http.get
    { url = timelineUrl
    , expect = Http.expectJson GotTimeline timelineDecoder
    }
