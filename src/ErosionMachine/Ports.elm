port module ErosionMachine.Ports exposing (..)

import Types exposing (..)
import Timeline.Types exposing (..)

port jsShowVideo : VideoData -> Cmd msg
port jsShowImage : ImageData -> Cmd msg
port jsShowText : TextData -> Cmd msg
port jsAddClass : AddClassData -> Cmd msg
-- FIXME: replace this with logick that unpacks assemblages
port jsShowAssemblage : String -> Cmd msg

port jsRollBack : List String -> Cmd msg
