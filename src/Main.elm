module Main exposing (..)
-- Press a button to send a GET request for random cat GIFs.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/json.html
--

import Browser
import Browser.Events as Events
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (viewMaybe)
import Http
import Json.Decode as D exposing (Decoder, field, string, int, bool, map2, list)
import Json.Decode.Extra as DE
import List as L
import Random
import Process
import Task
import Time

import Types exposing (..)
import Timeline.Decoder exposing (..)
import Timeline.Types exposing (..)
import Timeline.View
-- import Index.View
import ErosionMachine.ErosionMachine exposing (..)
import ErosionMachine.Ports exposing (jsThereAreNoTargets, jsSetAutoplayStatus)


import SplashScreen.SplashScreen exposing (..)
import SplashScreen.Types exposing (..)

-- MAIN


main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }


-- type Event
--     = Video String
--     | Text String
--     | Image String

init : String -> (Model, Cmd Msg)
init timelineUrl =
  (LoadingTimeline, getTimeline timelineUrl)


-- randomEvent : List Event -> Random.Generator (Maybe Event)
-- randomEvent es = Random.uniform (L.head es) (L.map (\x -> Just x) es)

-- changeRandomEvent : Timeline -> Event -> Cmd Msg
-- changeRandomEvent tl e =
--     case (getDuration e) of
--         Nothing -> Cmd.none
--         Just dur -> Process.sleep (toFloat dur) |> Task.perform (always (FireRandomEvent tl))

-- showEvent : Timeline -> Maybe Event -> Cmd Msg
-- showEvent tl e =
--     Cmd.batch [ Task.perform (always (ShowEmptyPage tl)) (Task.succeed ())
--               , Task.perform (always (ShowEvent tl e)) (Process.sleep 100)]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotTimeline result ->
      case result of
        Ok timeline ->
          ( Running
               { erosionModel = Waiting { timeline = timeline, counter = 0}
               , splashScreenModel = NotBornYet { text = timeline.config.splashScreenText}}
          , Cmd.batch [jsShowSplashScreen {}])
        Err s ->
          (ErrorLoadTimeline s, Cmd.none)

    --
    -- Plan erosion frame
    --
    PlanErosion (events, frameId) ->
        case handlePlanErosion events frameId
             |> handleSubModelResult l_erosionModel model
             |> Result.mapError (\s -> (Error s, Cmd.none)) of
            Ok v -> v
            Err e -> e

    --
    -- eroding
    --
    Erode event frameId ->
        handleSubModel l_erosionModel model <| handleErode event frameId
    UserInput ->
        handleSubModel l_erosionModel model <| handleUserInput
    TimeTick ->
        handleSubModel l_erosionModel model <| handleTimeTick
    RaiseError s ->
        (Error s, Cmd.none)
    PauseTimeline ->
        handleSubModel l_erosionModel model <| handlePauseTimeline
    SetAutoplayStatus status ->
        handleSubModel l_erosionModel model <| handleSetAutoplayStatus status
    CheckAutoplayStatus frameId ->
        handleSubModel l_erosionModel model <| handleCheckAutoplayStatus frameId
    --
    -- splash screen
    --
    SplashScreenIsShown ->
        handleSubModel l_splashScreenModel model <| handleSplashScreenIsShown
    SplashScreenClosed ->
        (model, Cmd.none)
    GrowSplashScreen ->
        handleSubModel l_splashScreenModel model <| handleGrowSplashScreen
    SplashScreenGotLanguage lang ->
        handleSubModel l_splashScreenModel model <| handleSplashScreenGotLanguage lang

    -- RandomEventFired tl mE ->
    --     case mE of
    --         Nothing -> (Error "error getting random event" tl, Cmd.none)
    --         Just e -> ( ViewEvent tl Nothing
    --                   , (Process.sleep 100 |> Task.perform (always (ShowEvent tl e))))
    -- ShowEvent tl e -> (ViewEvent tl (Just e), changeRandomEvent tl e)



userInputSub : (D.Decoder Msg -> Sub Msg) -> Sub Msg
userInputSub f =
    f (D.succeed UserInput)

userInputSubs : List (Sub Msg)
userInputSubs =
    [userInputSub Events.onClick
    , userInputSub Events.onMouseMove
    , userInputSub Events.onKeyUp]

timerSub : Sub Msg
timerSub =
    Time.every 1000 (always TimeTick)

splashScreenTimerSub : Sub Msg
splashScreenTimerSub =
    Time.every 8000 (always GrowSplashScreen)


thereAreNoTargetsSub : Sub Msg
thereAreNoTargetsSub =
    jsThereAreNoTargets (\ _ -> PauseTimeline )

splashScreenClosedSub : Sub Msg
splashScreenClosedSub =
    jsSplashScreenClosed (\ _ -> SplashScreenClosed )

splashScreenIsShownSub : Sub Msg
splashScreenIsShownSub =
    jsSplashScreenIsShown (\ _  -> SplashScreenIsShown)

gotLanguageSub : Sub Msg
gotLanguageSub =
    jsGotLanguage (\ lang -> SplashScreenGotLanguage (parseLang lang))

setAutoplayStatus : Sub Msg
setAutoplayStatus =
    jsSetAutoplayStatus (\ v -> SetAutoplayStatus v)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Running {erosionModel, splashScreenModel} ->
            Sub.batch [ erosionSubscriptions erosionModel
                      , splashScreenSubscriptions splashScreenModel ]
        _ -> Sub.none

erosionSubscriptions : ErosionModel -> Sub Msg
erosionSubscriptions model =
    case model of
        Showing _ ->
            Sub.batch <| setAutoplayStatus :: thereAreNoTargetsSub :: userInputSubs
        _ -> Sub.batch <| setAutoplayStatus :: thereAreNoTargetsSub :: timerSub :: userInputSubs

splashScreenSubscriptions : SplashScreenModel -> Sub Msg
splashScreenSubscriptions model =
    case model of
        NotBornYet _ -> Sub.batch [splashScreenIsShownSub, gotLanguageSub]
        Growing _ -> Sub.batch [splashScreenTimerSub, splashScreenClosedSub]
        Closed _ -> Sub.none


-- VIEW
view : Model -> Html Msg
view model =
  div [ style "display" "none"]
    [ viewModel model ]


viewModel : Model -> Html Msg
viewModel model =
  case model of
    ErrorLoadTimeline s ->
      div []
        [ text "error loading timeline"]

    LoadingTimeline ->
      div []
          [text "Loading timeline..."]

    Error msg ->
        text <| "ERROR: " ++ msg

    Running {erosionModel, splashScreenModel}->
        div []
            [ viewErosionStatus erosionModel
            , viewSplashScreenStatus splashScreenModel]


viewErosionStatus : ErosionModel -> Html Msg
viewErosionStatus model =
    case model of
        Waiting {counter} ->
            div []
                [text ("waiting " ++ (String.fromInt counter))]

        Showing {events} ->
            div []
                [text <| "showing " ++ (String.join ", " <| List.map getLabel <| List.map (\x -> x.event) events)]
        Paused _ ->
            div []
                [text "paused"]
        WaitingForAutoplayStatus _ ->
            div []
                [text "waiting for autoplay status"]

        WaitingForErosion _ ->
            div []
                [text "waiting for an erosion process starting"]

viewSplashScreenStatus : SplashScreenModel -> Html Msg
viewSplashScreenStatus model =
    case model of
        NotBornYet _ ->
            text "not born yet"
        Growing _ ->
            text "growing"
        Closed _ ->
            text "closed"
