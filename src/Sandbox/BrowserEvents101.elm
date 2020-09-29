module Sandbox.BrowserEvents101 exposing (..)

--
-- testing user input events
-- https://github.com/mpizenberg/elm-pointer-events
--

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Process
import Task
import Random
import Browser.Events as Events
import Json.Decode as D
import Time

main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view }

type Model
    = Starting
    | Counting Int

type Msg
    = UserInput
    | TimeTick

init : () -> (Model, Cmd Msg)
init _ =
    (Starting, Cmd.none)

tick : Model -> Model
tick m =
    case m of
        Starting -> m
        Counting i -> (Counting (i + 1))


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        UserInput ->
            (Counting 0, Cmd.none)
        TimeTick ->
            (tick model, Cmd.none)


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
        Starting -> text "starting"
        Counting i -> text <| "counting " ++ (String.fromInt i)
