port module ErosionMachine.Ports exposing (..)

import Types exposing (..)
import Timeline.Types exposing (..)

--
-- outbound ports
--
port jsShowVideo : VideoData -> Cmd msg
port jsShowImage : ImageData -> Cmd msg
port jsShowText : TextData -> Cmd msg
port jsAddClass : AddClassData -> Cmd msg
port jsHideElement : HideElementData -> Cmd msg
port jsRollBack : List String -> Cmd msg

port jsCheckAutoplayStatus : {} -> Cmd msg

--
-- inbound
--
port jsThereAreNoTargets : (String -> msg) -> Sub msg
port jsSetAutoplayStatus : (Bool -> msg) -> Sub msg
