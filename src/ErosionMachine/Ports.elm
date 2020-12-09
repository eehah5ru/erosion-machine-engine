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
port jsRemoveClass : RemoveClassData -> Cmd msg
port jsHideElement : HideElementData -> Cmd msg

-- rolling back
port jsRollBackShowVideo : VideoData -> Cmd msg
port jsRollBackShowImage : ImageData -> Cmd msg
port jsRollBackShowText : TextData -> Cmd msg
port jsRollBackAddClass : AddClassData -> Cmd msg
port jsRollBackRemoveClass : RemoveClassData -> Cmd msg
port jsRollBackHideElement : HideElementData -> Cmd msg

port jsCheckAutoplayStatus : {} -> Cmd msg

--
-- inbound
--
port jsThereAreNoTargets : (String -> msg) -> Sub msg
port jsSetAutoplayStatus : (Bool -> msg) -> Sub msg

port jsTouchMove : (String -> msg) -> Sub msg
