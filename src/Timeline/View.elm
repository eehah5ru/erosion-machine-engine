module Timeline.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (viewMaybe)

import Types exposing (..)
import Timeline.Types exposing (..)

renderVideo : VideoData -> Html Msg
renderVideo vd =
    video [ class vd.class
          , controls True
          , loop vd.loop
          , id vd.id
          , autoplay True
          ]
          [
             source [ type_ "video/mp4"
             , src vd.urlMP4] []
          ]

renderDuration : Event -> Html Msg
renderDuration e =
    let dur = case (getDuration e) of
                  Nothing -> "N/A"
                  Just d -> String.fromInt d
    in
            text ("duration: " ++ dur)

renderEvent : Event -> Html Msg
renderEvent e =
    div [] [renderDuration e, br [] [], doRenderEvent e]

doRenderEvent : Event -> Html Msg
doRenderEvent e =
    case e of
        ShowVideo vd -> div [] [renderVideo vd]

        ShowImage id -> text "image"
        ShowText td -> text "text"
        AddClass acd -> text "add_class"
        Assemblage ad -> text "assemblage"
