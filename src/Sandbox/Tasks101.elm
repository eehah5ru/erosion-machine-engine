module Sandbox.Tasks101 exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Process
import Task
import Random

main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view }

type Model
    = Starting
    | Delaying Int
    | StoppedHere
    -- | TimePoint Time.Posix

type Msg
    = StopIn Int
    | SelectTimePoint
    | JustLandedInTime

init : () -> (Model, Cmd Msg)
init _ =
    (Starting, selectTimePoint)


selectTimePoint : Cmd Msg
selectTimePoint =
    Random.generate StopIn (Random.int 1000 3000)

goThroughTime : Int -> Cmd Msg
goThroughTime del =
    Process.sleep (toFloat del) |> Task.perform (always SelectTimePoint)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        StopIn del -> (Delaying del, goThroughTime del)
        SelectTimePoint -> (model, selectTimePoint)
        JustLandedInTime -> (StoppedHere, selectTimePoint)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

view : Model -> Html Msg
view model =
    case model of
        Starting -> text "starting"
        Delaying del -> text (String.append "delaying " (String.fromInt del))
        StoppedHere -> div [] [button [ onClick SelectTimePoint ] [ text "go through time" ]]
