module Index.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (viewMaybe)
import List as L

import Types exposing (..)
import Timeline.Types exposing (..)


renderEvent : Event -> Html Msg
renderEvent e =
    li [] [ text (getLabel e)
          , text " / "
          , text <| getType e
          , text " / "
          , viewMaybe (\x -> text <| String.fromInt <| x) (getDuration e)]

renderEvents : List Event -> Html Msg
renderEvents es =
    let evs = L.map renderEvent es
    in
        ul [] evs

-- buttonFireRandomEvent : Timeline -> Html Msg
-- buttonFireRandomEvent timeline =
--     button [ onClick (FireRandomEvent timeline), style "display" "block" ] [ text "fire random event" ]


render : Timeline -> Html Msg
render timeline =
    div []
        [
        renderEvents timeline.events]
