module SplashScreen.Types exposing (..)

import Timeline.Types exposing (SplashScreenText)


type Lang = EN | RU

type alias CycledText = (List String, List String)


type SplashScreenModel
    = NotBornYet
      { text : SplashScreenText }
    | Growing
      { text : SplashScreenText
      , cycledText : CycledText
      , lang : Lang }
    | Closed
      { text : SplashScreenText
      , lang : Lang}


defaultLang = EN

parseLang : String -> Lang
parseLang rawLang =
    let parseRu s  =
            if String.contains "ru" s then
                Ok RU
            else
                Err s
        parseEn s =
            if String.contains "en" s then
                Ok EN
            else
                Err s
    in
        parseRu rawLang
            |> Result.mapError parseEn
            |> Result.withDefault defaultLang

mkCycledText : Lang -> SplashScreenText -> CycledText
mkCycledText lang {ru, en} =
    case lang of
        RU -> (ru, ru)
        EN -> (en, en)
