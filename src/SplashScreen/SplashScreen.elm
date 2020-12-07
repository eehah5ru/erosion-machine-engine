port module SplashScreen.SplashScreen exposing (..)

import Types exposing (..)
import SplashScreen.Types exposing (..)



--
--
-- update handlers
--
--

handleSplashScreenIsShown : SplashScreenModel
                          -> (SplashScreenModel, Cmd Msg)
handleSplashScreenIsShown model =
    case model of
        NotBornYet _ -> (model, jsAskLanguage ())
        _ -> (model, Cmd.none)

handleSplashScreenGotLanguage : Lang
                              -> SplashScreenModel
                              -> (SplashScreenModel, Cmd Msg)
handleSplashScreenGotLanguage lang model =
    case model of
        NotBornYet d -> (Growing { text = d.text
                                 , cycledText = mkCycledText lang d.text
                                 , lang = lang}
                        , Cmd.none)
        _ -> (model, Cmd.none)

handleGrowSplashScreen : SplashScreenModel
                       -> (SplashScreenModel, Cmd Msg)
handleGrowSplashScreen model =
    case model of
        Growing ({cycledText} as d) ->
            let (v, newCycledText) = cycleText cycledText
            in
                (Growing {d | cycledText = newCycledText}, jsGrowSplashScreen v)
        _ -> (model, Cmd.none)



cycleText : CycledText -> (String, CycledText)
cycleText (currentChunk, wholeText) =
    let f v newChunk =
            \ () -> (v, (newChunk, wholeText))
        getResult = Maybe.withDefault (\ () -> cycleText (wholeText, wholeText))
                       <| Maybe.map2 f (List.head currentChunk) (List.tail currentChunk)
    in
        getResult ()
--
--
-- ports
--
--

--
-- outbound
--
port jsShowSplashScreen : {} -> Cmd msg
port jsGrowSplashScreen : String -> Cmd msg
port jsAskLanguage : () -> Cmd msg

--
-- inbound
--
port jsSplashScreenIsShown : (String -> msg) -> Sub msg
port jsSplashScreenClosed : (String -> msg) -> Sub msg
port jsGotLanguage : (String -> msg) -> Sub msg
