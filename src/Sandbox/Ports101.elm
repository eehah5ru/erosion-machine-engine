port module Sandbox.Ports101 exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Browser.Events as Events
import Process
import Task
import Random
import Time
import Json.Decode as D


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view }

type Model
    = Counting Int
    | Showing (List Int) Int

type Msg
    = Erode Int
    | SelectNextErosion
    | UserInput
    | TimeTick

init : () -> (Model, Cmd Msg)
init _ =
    (Counting 0, Cmd.none)


selectErosion : Cmd Msg
selectErosion =
    Random.generate Erode (Random.int 1000 3000)

showErosion : Int -> Cmd Msg
showErosion del =
    Process.sleep (toFloat del) |> Task.perform (always SelectNextErosion)

tick : Model -> Model
tick m =
    case m of
        Showing _ _ -> m
        Counting i -> (Counting (i + 1))

erode : Model -> Int -> Model
erode m eId =
    case m of
        Counting _ -> Showing [eId] eId
        Showing showed _ -> Showing (eId :: showed) eId

timeTickCmd : Model -> Cmd Msg
timeTickCmd m =
    case m of
        Showing _ _ ->
            Cmd.none
        Counting i ->
            if i > 5 then
                selectErosion
            else
                Cmd.none

userInputCmd : Model -> Cmd Msg
userInputCmd m =
    case m of
        Showing showed _ ->
            jsRollBack showed
        _ -> Cmd.none



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        -- showing erosions
        Erode eId ->
            (erode model eId, Cmd.batch [showErosion eId, jsErode eId])
        SelectNextErosion ->
            case model of
                Showing _ _ -> (model, selectErosion)
                _ -> (model, Cmd.none)
        -- handle interruptions
        UserInput ->
            (Counting 0, userInputCmd model)
        TimeTick ->
            (tick model, timeTickCmd model)


userInputSub : (D.Decoder Msg -> Sub Msg) -> Sub Msg
userInputSub f =
    f (D.succeed UserInput)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch [ userInputSub Events.onClick
            , userInputSub Events.onMouseMove
            , userInputSub Events.onKeyUp
            , Time.every 1000 (always TimeTick)]

view : Model -> Html Msg
view model =
    case model of
        Showing _ eId -> text (String.append "showing " (String.fromInt eId))
        Counting del -> text ("waiting " ++ (String.fromInt del))


--
-- ports
--
port jsErode : Int -> Cmd msg
port jsRollBack : List Int -> Cmd msg
