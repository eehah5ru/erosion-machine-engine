module Timeline.TestDecoder exposing (..)

import Json.Decode as D exposing (Decoder, field, string, int, bool, map2, list)

import Timeline.Types exposing (..)
import Timeline.Decoder exposing (..)

testTimeline =
    """
     {"config":{"delay":5,"disabled":false},"timeline":[{"events":[{"class":"erosion erosion-image outsourcing-orgy-image","src":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/images/outsourcing-orgy.svg","id":"outsourcing-orgy-image","duration":6000,"type":"showImage","label":"outsourcing-orgy-image"},{"class":"outsourcing-orgy-image-growing","delayed":2000,"id":"outsourcing-orgy-image","type":"addClass","label":"outsourcing-orgy-image-growing"}],"type":"assemblage","label":"outsourcing-orgy-assemblage"},{"class":"erosion erosion-image general-intellect-care-image","src":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/images/general-intellect-care.gif","id":"general-intellect-care-image","duration":13520,"type":"showImage","position":"absolute","label":"general-intellect-care-image"},{"events":[{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/water-in-office-01.mp4_ru.vtt","class":"erosion erosion-video water-in-office-01-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/water-in-office-01.mp4_en.vtt","id":"water-in-office-01-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/water-in-office-01.mp4","duration":42091,"type":"showVideo","label":"water-in-office-01-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/water-in-office-02.mp4_ru.vtt","class":"erosion erosion-video water-in-office-02-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/water-in-office-02.mp4_en.vtt","id":"water-in-office-02-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/water-in-office-02.mp4","duration":30623,"type":"showVideo","label":"water-in-office-02-video"},{"class":"erosion erosion-text water-in-office-text-01","id":"water-in-office-text-01","text":"nest of absence","duration":42091,"type":"showText","label":"water-in-office-text-01"},{"class":"erosion erosion-text water-in-office-text-02","id":"water-in-office-text-02","text":"interface cannibalism","duration":42091,"type":"showText","label":"water-in-office-text-02"}],"type":"assemblage","label":"water-in-office-assemblage"},{"events":[{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/pause.mp4_ru.vtt","class":"erosion erosion-video pause-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/pause.mp4_en.vtt","id":"pause-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/pause.mp4","duration":215766,"type":"showVideo","label":"pause-video"},{"class":"erosion erosion-text pause-text","id":"pause-text","text":"4-MINUTES PAUSE","duration":215766,"type":"showText","label":"pause-text"}],"type":"assemblage","label":"pause-assemblage"},{"events":[{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-watchdog-session.mp4_ru.vtt","class":"erosion erosion-video watchdog-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-watchdog-session.mp4_en.vtt","loop":false,"id":"watchdog-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-watchdog-session.mp4","duration":42624,"type":"showVideo","position":"absolute","label":"watchdog-video"},{"class":"erosion erosion-text watchdog-text-01","id":"watchdog-text-01","text":"Watchdog position","duration":42624,"type":"showText","position":"absolute","label":"watchdog-text-01"},{"class":"erosion erosion-text watchdog-text-02","id":"watchdog-text-02","text":"allows algorithms to make sure that you are neither a script nor a bot, but a human","duration":42624,"type":"showText","label":"watchdog-text-02"}],"type":"assemblage","label":"watchdog-assemblage"},{"events":[{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-kot-odin.mp4_ru.vtt","class":"erosion erosion-video kot-odin-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-kot-odin.mp4_en.vtt","loop":false,"id":"kot-odin-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-kot-odin.mp4","duration":11328,"type":"showVideo","position":"absolute","label":"kot-odin-video"},{"class":"erosion erosion-text kot-odin-text","id":"kot-odin-text","text":"Together let's find a gesture that will be algorithmized well","duration":11328,"type":"showText","label":"kot-odin-text"}],"type":"assemblage","label":"kot-odin-assemblage"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/cradle-song-01.mp4_ru.vtt","class":"erosion erosion-video spinner-spi","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/cradle-song-01.mp4_en.vtt","loop":false,"id":"spinner-spi","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/cradle-song-01.mp4","duration":66198,"type":"showVideo","position":"absolute","label":"spinner-spi"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/cradle-song-02-screen.mp4_ru.vtt","class":"erosion erosion-video screen-is-blinking-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/cradle-song-02-screen.mp4_en.vtt","loop":false,"id":"screen-is-blinking-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/cradle-song-02-screen.mp4","duration":114923,"type":"showVideo","position":"absolute","label":"screen-is-blinking-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/cradle-song-03-blur.mp4_ru.vtt","class":"erosion erosion-video cradle-song-03-blur-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/cradle-song-03-blur.mp4_en.vtt","loop":false,"id":"cradle-song-03-blur-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/cradle-song-03-blur.mp4","duration":87360,"type":"showVideo","position":"absolute","label":"cradle-song-03-blur-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/dominatrix-volgograd-01.mp4_ru.vtt","class":"erosion erosion-video dominatrix-volgograd-01-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/dominatrix-volgograd-01.mp4_en.vtt","loop":false,"id":"dominatrix-volgograd-01-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/dominatrix-volgograd-01.mp4","duration":14507,"type":"showVideo","position":"absolute","label":"dominatrix-volgograd-01-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/perezagruzka.mp4_ru.vtt","class":"erosion erosion-video perezagruzka-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/perezagruzka.mp4_en.vtt","loop":false,"id":"perezagruzka-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/perezagruzka.mp4","duration":5163,"type":"showVideo","position":"absolute","label":"perezagruzka-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/scroll-rab.mp4_ru.vtt","class":"erosion erosion-video scroll-rab-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/scroll-rab.mp4_en.vtt","loop":false,"id":"scroll-rab-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/scroll-rab.mp4","duration":9131,"type":"showVideo","position":"absolute","label":"scroll-rab-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/sleep-vertical.mp4_ru.vtt","class":"erosion erosion-video sleep-vertical-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/sleep-vertical.mp4_en.vtt","loop":false,"id":"sleep-vertical-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/sleep-vertical.mp4","duration":58624,"type":"showVideo","position":"absolute","label":"sleep-vertical-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-dorogoi-posetitel-kluba.mp4_ru.vtt","class":"erosion erosion-video spinner-dorogoi-posetitel-kluba-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-dorogoi-posetitel-kluba.mp4_en.vtt","loop":false,"id":"spinner-dorogoi-posetitel-kluba-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-dorogoi-posetitel-kluba.mp4","duration":61056,"type":"showVideo","position":"absolute","label":"spinner-dorogoi-posetitel-kluba-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-konec.mp4_ru.vtt","class":"erosion erosion-video spinner-konec-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-konec.mp4_en.vtt","loop":false,"id":"spinner-konec-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-konec.mp4","duration":9430,"type":"showVideo","position":"absolute","label":"spinner-konec-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/stop-word-vertical.mp4_ru.vtt","class":"erosion erosion-video stop-word-vertical-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/stop-word-vertical.mp4_en.vtt","loop":false,"id":"stop-word-vertical-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/stop-word-vertical.mp4","duration":4694,"type":"showVideo","position":"absolute","label":"stop-word-vertical-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/taxi-driver.mp4_ru.vtt","class":"erosion erosion-video taxi-driver-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/taxi-driver.mp4_en.vtt","loop":false,"id":"taxi-driver-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/taxi-driver.mp4","duration":19136,"type":"showVideo","position":"absolute","label":"taxi-driver-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/user-experience-vertical.mp4_ru.vtt","class":"erosion erosion-video user-experience-vertical-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/user-experience-vertical.mp4_en.vtt","loop":false,"id":"user-experience-vertical-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/user-experience-vertical.mp4","duration":59435,"type":"showVideo","position":"absolute","label":"user-experience-vertical-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/vremya-prikljucheniy-nastupilo.mp4_ru.vtt","class":"erosion erosion-video vremya-prikljucheniy-nastupilo-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/vremya-prikljucheniy-nastupilo.mp4_en.vtt","loop":false,"id":"vremya-prikljucheniy-nastupilo-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/vremya-prikljucheniy-nastupilo.mp4","duration":14998,"type":"showVideo","position":"absolute","label":"vremya-prikljucheniy-nastupilo-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-krutit-spinner-04.mp4_ru.vtt","class":"erosion erosion-video spinner-krutit-spinner-04-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-krutit-spinner-04.mp4_en.vtt","loop":false,"id":"spinner-krutit-spinner-04-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-krutit-spinner-04.mp4","duration":19456,"type":"showVideo","position":"absolute","label":"spinner-krutit-spinner-04-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-ya-vhozhu-vo-vkus.mp4_ru.vtt","class":"erosion erosion-video spinner-ya-vhozhu-vo-vkus-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-ya-vhozhu-vo-vkus.mp4_en.vtt","loop":false,"id":"spinner-ya-vhozhu-vo-vkus-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/spinner-ya-vhozhu-vo-vkus.mp4","duration":28608,"type":"showVideo","position":"absolute","label":"spinner-ya-vhozhu-vo-vkus-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/interface-dominatrix-01.mp4_ru.vtt","class":"erosion erosion-video interface-dominatrix-01-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/interface-dominatrix-01.mp4_en.vtt","loop":false,"id":"interface-dominatrix-01-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/interface-dominatrix-01.mp4","duration":5824,"type":"showVideo","position":"absolute","label":"interface-dominatrix-01-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-01-vertical.mp4_ru.vtt","class":"erosion erosion-video panic-attack-new-01-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-01-vertical.mp4_en.vtt","loop":false,"id":"panic-attack-new-01-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-01-vertical.mp4","duration":32768,"type":"showVideo","position":"absolute","label":"panic-attack-new-01-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-02-vertical.mp4_ru.vtt","class":"erosion erosion-video panic-attack-new-02-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-02-vertical.mp4_en.vtt","loop":false,"id":"panic-attack-new-02-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-02-vertical.mp4","duration":32683,"type":"showVideo","position":"absolute","label":"panic-attack-new-02-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-04-vertical.mp4_ru.vtt","class":"erosion erosion-video panic-attack-new-04-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-04-vertical.mp4_en.vtt","loop":false,"id":"panic-attack-new-04-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-04-vertical.mp4","duration":43200,"type":"showVideo","position":"absolute","label":"panic-attack-new-04-video"},{"subtitles_ru":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-05-vertical.mp4_ru.vtt","class":"erosion erosion-video panic-attack-new-05-video","subtitles_en":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-05-vertical.mp4_en.vtt","loop":false,"id":"panic-attack-new-05-video","url_mp4":"https://dev.eeefff.org/data/outsourcing-paradise-parasite/videos/panic-attack-new-05-vertical.mp4","duration":62422,"type":"showVideo","position":"absolute","label":"panic-attack-new-05-video"}]}
"""

testTimelineDecoder = D.decodeString timelineDecoder testTimeline
