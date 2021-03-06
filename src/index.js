import './main.css';
import './erosion-machine-timeline.css';

import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
// import _ from 'lodash';
var _ = require("lodash");
var jQuery = require("jquery");
import canAutoPlay from 'can-autoplay';
// var canAutoplay = require("can-autoplay");

import * as _invoke from "lodash.invoke";
// import * as jQuery from 'jquery';

// import * as $visible from 'jquery-visible';
// var jVisible = require('jquery-visible');

//
//
// DEBUG DEPS
//
//
console.log("[erosion-deps] jquery ==", jQuery);
console.log("[erosion-deps] _ ==", _);
console.log("[erosion-deps] Elm ==", Elm);
console.log("[erosion-deps] canAutoplay ==", canAutoPlay);


//
// jquery random plugin
//
(function ($) {
  $.fn.random = function() {
    var randomIndex = Math.floor(Math.random() * this.length);
    return jQuery(this[randomIndex]);
  };
})(jQuery);


//
// jquery deepest plugin
//
(function ($) {
    $.fn.deepest = function (selector) {
        var deepestLevel  = 0,
            $deepestChild,
            $deepestChildSet;

        this.each(function () {
            var $parent = $(this);
            $parent
                .find((selector || '*'))
                .each(function () {
                    if (!this.firstChild || this.firstChild.nodeType !== 1) {
                        var levelsToParent = $(this).parentsUntil($parent).length;
                        if (levelsToParent > deepestLevel) {
                            deepestLevel = levelsToParent;
                            $deepestChild = $(this);
                        } else if (levelsToParent === deepestLevel) {
                            $deepestChild = !$deepestChild ? $(this) : $deepestChild.add(this);
                        }
                    }
                });
            $deepestChildSet = !$deepestChildSet ? $deepestChild : $deepestChildSet.add($deepestChild);
        });

        return this.pushStack($deepestChildSet || [], 'deepest', selector || '');
    };
}(jQuery));

(function($){

    /**
     * Copyright 2012, Digital Fusion
     * Licensed under the MIT license.
     * http://teamdf.com/jquery-plugins/license/
     *
     * @author Sam Sehnert
     * @desc A small plugin that checks whether elements are within
     *       the user visible viewport of a web browser.
     *       only accounts for vertical position, not horizontal.
     */
    $.fn.visible = function(partial,hidden,direction,container){

        if (this.length < 1)
            return;

        var $t          = this.length > 1 ? this.eq(0) : this,
            isContained = typeof container !== 'undefined' && container !== null,
            $w          = isContained ? $(container) : $(window),
            wPosition        = isContained ? $w.position() : 0,
            t           = $t.get(0),
            vpWidth     = $w.outerWidth(),
            vpHeight    = $w.outerHeight(),
            direction   = (direction) ? direction : 'both',
            clientSize  = hidden === true ? t.offsetWidth * t.offsetHeight : true;

        if (typeof t.getBoundingClientRect === 'function'){

            // Use this native browser method, if available.
            var rec = t.getBoundingClientRect(),
                tViz = isContained ?
                        rec.top - wPosition.top >= 0 && rec.top < vpHeight + wPosition.top :
                        rec.top >= 0 && rec.top < vpHeight,
                bViz = isContained ?
                        rec.bottom - wPosition.top > 0 && rec.bottom <= vpHeight + wPosition.top :
                        rec.bottom > 0 && rec.bottom <= vpHeight,
                lViz = isContained ?
                        rec.left - wPosition.left >= 0 && rec.left < vpWidth + wPosition.left :
                        rec.left >= 0 && rec.left <  vpWidth,
                rViz = isContained ?
                        rec.right - wPosition.left > 0  && rec.right < vpWidth + wPosition.left  :
                        rec.right > 0 && rec.right <= vpWidth,
                vVisible   = partial ? tViz || bViz : tViz && bViz,
                hVisible   = partial ? lViz || rViz : lViz && rViz;

            if(direction === 'both')
                return clientSize && vVisible && hVisible;
            else if(direction === 'vertical')
                return clientSize && vVisible;
            else if(direction === 'horizontal')
                return clientSize && hVisible;
        } else {

            var viewTop         = isContained ? 0 : wPosition,
                viewBottom      = viewTop + vpHeight,
                viewLeft        = $w.scrollLeft(),
                viewRight       = viewLeft + vpWidth,
                position          = $t.position(),
                _top            = position.top,
                _bottom         = _top + $t.height(),
                _left           = position.left,
                _right          = _left + $t.width(),
                compareTop      = partial === true ? _bottom : _top,
                compareBottom   = partial === true ? _top : _bottom,
                compareLeft     = partial === true ? _right : _left,
                compareRight    = partial === true ? _left : _right;

            if(direction === 'both')
                return !!clientSize && ((compareBottom <= viewBottom) && (compareTop >= viewTop)) && ((compareRight <= viewRight) && (compareLeft >= viewLeft));
            else if(direction === 'vertical')
                return !!clientSize && ((compareBottom <= viewBottom) && (compareTop >= viewTop));
            else if(direction === 'horizontal')
                return !!clientSize && ((compareRight <= viewRight) && (compareLeft >= viewLeft));
        }
    };

})(jQuery);

//
// END OF JQUERY PLUGINS
//

//
// check if element is in the eroded branch or in the erosion branch of els;
//
function isErodedBranch(e) {
  if (jQuery(e).is(":root")) {
    return false;
  }

  if (jQuery(e).hasClass('erosion')) {
    return true;
  }

  if (jQuery(e).hasClass('eroded')) {
    return true;
  }

  return isErodedBranch(jQuery(e).parent());
}

//
// get target element for the erosion
//
function getTarget() {
  const log = _.partial(console.log, `[getTarget]`);

  // uncomment to test final event
  // return jQuery();

  // deepest the most of time
  // let findFn = _.chain(["deepest", "deepest", "deepest", "find"]).shuffle().head().value();

  // log("using", findFn);

  // TODO: tell elm if there is not any elements to erode
  // TODO: do not erode erosion elements added by jsErode func
  let q = jQuery("body").find(":not(.eroded)");

  // log("deepest els count: " + q.length);

  let els = q
      .filter(function() {
        if (isErodedBranch(this)) {
          log("filtred out cuz branch is eroded");
          return false;
        }
        return true;
      })
      .filter(function() {
        return jQuery(this).visible(true, true);
      })
      .filter(function() {
        // filter elements by size not smaller than threshold
        if (this.getBoundingClientRect().height < 10) {
          log("filtred out cuz of too small height");
          return false;
        }
        if (this.getBoundingClientRect().width < 10) {
          log("filtred out cuz of too small width");
          return false;
        }
        return true;
      })
      .toArray();

  log(`erosion possibilities: ${els.length}`);

  let result =  _.chain(els)
  // sort by squares
    .sortBy((e) => {
      return e.getBoundingClientRect().height * e.getBoundingClientRect().width;
    })
  // get some smallest
    .take(10)
    .sample()
    .value();

  if (_.isNil(result)) {
    return jQuery();
  }

  log(`eroded el's square: ${result.getBoundingClientRect().height * result.getBoundingClientRect().width}`);

  return jQuery(result);
};

//
// replace dom element
//
function replaceElement(el, onError) {
  const log = _.partial(console.log, `[replaceElement/${el.id}]`);
  const error = _.partial(console.error, `[replaceElement/${el.id}]`);
  //log('element', el);

  var target = getTarget();
  //log(target.length);

  if (target.length == 0) {
    error("there are no targets");
    onError("there are no targets");
    throw "there are no targets";
  }

  // using label because ids are unique for frames but we need to roll back multipe frames when we know labels only
  // FIXME: make this process more transparent
  jQuery(target).attr(`data-replaced-with-${el.label}`, true);

  jQuery(target).addClass("eroded");

  try {
    jQuery(el).insertAfter(jQuery(target));
  } catch (e) {
    error('error:', e);
    error('el doc:', el.ownerDocument);
    error('target doc:', target.ownerDocument);
    throw e;
  }

  jQuery(target).hide();
}


//
// make an overlay
//
function overlayElement(el, onError) {
  const log = _.partial(console.log, `[overlayElement/${el.id}]`);
  const error = _.partial(console.error, `[overlayElement/${el.id}]`);

  jQuery(el).addClass("op-overlay");

  jQuery("body").append(el);

}


//
// do erosion
// kinda broker funciton
//
function erode(el, onError) {
  const log = _.partial(console.log, `[erode/${el.id}]`);
  const error = _.partial(console.error, `[erode/${el.id}]`);

  const position = _.get(el, "eventData.position", "replace");

  log("position: ", position);
  log("eventData: ", el.eventData);

  if (_.eq(position, "replace")) {
    return replaceElement(el, onError);
  }

  if (_.eq(position, "overlay")) {
    return overlayElement(el, onError);
  }

  throw(`unknown position: ${position}`);
}

//
// do rollback for show* events
//
function rollBackShowEvent(eventData) {
  const log = _.partial(console.log, '[roll-back-show-event]');

  //log('ids to roll back', erodedIds);

  // remove subtitles
  jQuery(".subtitle-box").remove();

  const eId = eventData.label;

  jQuery(`.${eId}`).remove();

  const e = jQuery(`[data-replaced-with-${eId}=true]`);
  e.removeClass("eroded");
  e.removeAttr(`data-replaced-with-${eId}`);
  e.show();
}

//
// play video
//
function playVideo(videoElement) {
  const log = _.partial(console.log, `[playVideo/${videoElement.id}]`);
  const error = _.partial(console.error, `[playVideo/${videoElement.id}]`);

  //
  // create subtitles
  //
  let subtitlesElement = document.createElement('div');
  jQuery(subtitlesElement).addClass("subtitle-box");
  jQuery(subtitlesElement).addClass("erosion");
  jQuery(subtitlesElement).addClass("eroded");
  jQuery("body").append(subtitlesElement);


  //
  // run subtitles
  //
  videoElement.textTracks[0].oncuechange = function() {
    try {
      subtitlesElement.innerText = _.get(
        videoElement,
        'textTracks[0].activeCues[0].text',
        ''
      );
    } catch (err) {
      error('error adding subtitle', err);
    }
  };

  //
  // delete subtitles when finished
  //
  jQuery(videoElement).on('ended', function() {
    jQuery(subtitlesElement).remove();
  });

  let promise = videoElement.play();

  if (promise !== undefined) {
    promise
      .then(() => {
        log('started');
      })
      .catch(e => {
       error('error starting video:', e);
      });
  }
}

//
// create base element
// returns DOM element with 'eventData' set to data recieved from elm
function createBaseErosionElement(eType, data) {
  let e = document.createElement(eType);

  e.id = _.get(data, 'id', _.uniqueId());
  e.classList = _.get(data, 'class', '');
  e.label = _.get(data, 'label', '');

  e.eventData = data;

  jQuery(e).addClass('eroded');
  jQuery(e).addClass(_.get(data, 'label', ''));     // add label as class to use it in roll back

  return e;
}

//
// stub element
//
// FIXME: remove when all ports will be implemented
function stubElement(stubData) {
  let e = createBaseErosionElement("span", stubData);

  e.innerText = _.get(stubData, 'id', '');

  return e;
}

//
//
// END OF UTILS
//
//

//
// splash screen factory
//
function showSplashScreen(handlers) {
  let e = document.createElement('div');

  e.id = "op-erosion-splash-screen";
  e.classList = 'eroded';

  const $textContainer = jQuery(document.createElement('div'));

  $textContainer.addClass("text-container");

  jQuery(e).append($textContainer);

  let h1 = document.createElement('h1');
  h1.textContent = "enter";
  h1.classList = "active";

  let h1Empty = document.createElement('h1');
  h1Empty.textContent = "enter";


  jQuery($textContainer).append(h1);
  jQuery($textContainer).append(h1Empty);

  jQuery(h1).add(h1Empty).click(() => {
    handlers.onClose("splash screen closed");
    jQuery(e).hide();
  });

  // jQuery(e).hide();

  jQuery("body").append(e);

  // jQuery(e)
  //   .css("top", function() {
  //     const curHeight = jQuery(this).height();

  //     return _.random(0, jQuery(window).height() - curHeight);
  //   })
  //   .css("left", function() {
  //     const curWidth = jQuery(this).width();

  //     return _.random(0, jQuery(window).width() - curWidth);
  //   })
  //   .show();

  handlers.onIsShown("splash screen is shown");

}

//
//
// EROSION MACHINE RUNNER
//
//
function runErosionMachine() {
  //
  // setup
  //

  console.log("[runErosionMachine] starting");

  const timelineUrl = document.getElementById('timeline-url').value;

  const erosionMachine = Elm.Main.init({
    node: document.getElementById('root'),
    flags: timelineUrl
  });

  // If you want your app to work offline and load faster, you can change
  // unregister() to register() below. Note this comes with some pitfalls.
  // Learn more about service workers: https://bit.ly/CRA-PWA
  serviceWorker.unregister();

  //
  //
  // incoming ports
  //
  //

  //
  // show video
  //
  erosionMachine.ports.jsShowVideo.subscribe(function(videoData) {
    const log = _.partial(console.log, `[showVideo/${videoData.id}]`);
    const error = _.partial(console.error, `[showVideo/${videoData.id}]`);
    const warning = _.partial(console.warn, `[showVideo/${videoData.id}]`);

    //log('data', videoData);

    let e = createBaseErosionElement('video', videoData);

    e.loop = _.get(videoData, 'loop', 'false');
    e.preload = 'auto';
    e.crossOrigin = 'anonymous';

    let sourceElement = document.createElement('source');
    sourceElement.src = _.get(videoData, 'urlMP4', '');
    sourceElement.type = 'video/mp4';

    if (_.get(videoData, 'muted', false)) {
      e.muted = true;

      warning("video gonna play muted");
    }

    jQuery(sourceElement).addClass('erosion');

    try {
      e.appendChild(sourceElement);
    } catch (err) {
      error('error adding source element', err);
      throw err;
    }

    if (_.has(videoData, 'subtitlesEn')) {
      let track = _.merge(document.createElement('track'),
                          {
                            kind: 'metadata',
                            label: 'English subtitles',
                            src: videoData.subtitlesEn,
                            srcLang: 'en',
                            default: true
                          });

      jQuery(track).addClass('erosion');

      try {
        e.appendChild(track);
      } catch (err) {
        error('error adding track element', err);
        throw err;
      }
    }

    if (_.has(videoData, 'subtitlesRu')) {
      let track = _.merge(document.createElement('track'),
                          {
                            kind: 'metadata',
                            label: 'Russian subtitles',
                            src: videoData.subtitlesRu,
                            srcLang: 'ru'
                          });
      jQuery(track).addClass('erosion');

      try {
        e.appendChild(track);
      } catch (err) {
        error('error adding track element', err);
        throw err;
      }
    }

    try {
      erode(e, erosionMachine.ports.jsThereAreNoTargets.send);

      playVideo(e);

    } catch (err) {
      error("eroding error: ", err);
    }
  });

  //
  // show image
  //
  erosionMachine.ports.jsShowImage.subscribe(function(imageData) {
    const log = _.partial(console.log, '[showImage]');
    const error = _.partial(console.error, '[showImage]');

    //log('data', imageData);

    let e = createBaseErosionElement('img', imageData);
    e.src = _.get(imageData, 'src', '');

    try {
      erode(e, erosionMachine.ports.jsThereAreNoTargets.send);
    } catch (err) {
      error("eroding error: ", err);
    }
  });

  //
  // show text
  //
  erosionMachine.ports.jsShowText.subscribe(function(textData) {
    const log = _.partial(console.log, '[showText]');
    const error = _.partial(console.error, '[showText]');

    //log('data', textData);

    let e = createBaseErosionElement('span', textData);
    e.textContent = textData.text;

    try {
      erode(e, erosionMachine.ports.jsThereAreNoTargets.send);
    } catch (err) {
      error("eroding error: ", err);
    }
  });

  //
  // add class
  //
  // FIXME: implement actual logic!
  erosionMachine.ports.jsAddClass.subscribe(function(addClassData) {
    const log = _.partial(console.log, '[addClass]');
    const error = _.partial(console.error, '[addClass]');
    //log('data', addClassData);

    var target = jQuery();    // empty set by default

    if (_.isEmpty(addClassData.selector)) {
      //
      // adding class by an id of html element
      //

      target = jQuery(`#${addClassData.id}`);

      if (target.length == 0) {
        error("no target for id " + addClassData.id);
        return;
      }
    } else {
      //
      // adding class by selector
      //

      target = jQuery(addClassData.selector);
      if (target.length == 0) {
        error("no target for selector " + addClassData.selector);
        return;
      }
    }

    target.addClass(addClassData.class);
    target.attr(`data-replaced-with-${addClassData.label}`, true);
    // target.addClass("eroded");


  });

  //
  // remove class
  //
  erosionMachine.ports.jsRemoveClass.subscribe(function(removeClassData) {
    const log = _.partial(console.log, '[remove-class]');
    const error = _.partial(console.error, '[remove-class]');

    var target = jQuery();    // empty set by default

    if (_.isEmpty(removeClassData.selector)) {
      //
      // removing class by an id of html element
      //

      log(`removing ${removeClassData.class} class from element with id ${removeClassData.id}`);

      target = jQuery(`#${removeClassData.id}`);

      if (target.length == 0) {
        error("no target for id " + removeClassData.id);
        return;
      }
    } else {
      //
      // removing class by selector
      //

      log(`removing ${removeClassData.class} class from elements by selector '${removeClassData.selector}'`);

      target = jQuery(removeClassData.selector);

      if (target.length == 0) {
        error("no target for selector " + removeClassData.selector);
        return;
      }
    }

    target.removeClass(removeClassData.class);
    target.removeClass("eroded");
  });

  //
  // hide element
  //
  erosionMachine.ports.jsHideElement.subscribe(function(hideElementData) {
    const log = _.partial(console.log, '[hideElement]');
    const error = _.partial(console.error, '[hideElement]');

    log(hideElementData.label);

    var target = getTarget();

    // stop eroding if there are no targets found
    if (target.length == 0) {
      error("there are no targets");
      erosionMachine.ports.jsThereAreNoTargets.send("there are no targets");
      return;
    }

    // using label because ids are unique for frames but we need to roll back multipe frames when we know labels only
    // FIXME: make this process more transparent
    jQuery(target).attr(`data-replaced-with-${hideElementData.label}`, true);
    jQuery(target).addClass("eroded");

    jQuery(target).hide();

  });

  //
  // elm port jsRollBackShowVideo
  //
  erosionMachine.ports.jsRollBackShowVideo.subscribe(function(videoData) {
    rollBackShowEvent(videoData);
  });

  //
  // elm port jsRollBackShowImage
  //
  erosionMachine.ports.jsRollBackShowImage.subscribe(function(imageData) {
    rollBackShowEvent(imageData);
  });

  //
  // elm port jsRollBackShowText
  //
  erosionMachine.ports.jsRollBackShowText.subscribe(function(textData) {
    rollBackShowEvent(textData);
  });

  //
  // elm port jsRollBackHideElement
  //
  erosionMachine.ports.jsRollBackShowText.subscribe(function(hideElementData) {
    const e = jQuery(`[data-replaced-with-${hideElementData.label}=true]`);
    e.removeClass("eroded");
    e.removeAttr(`data-replaced-with-${hideElementData.label}`);
    e.show();
  });

  //
  // elm port jsRollBackAddClass
  //
  erosionMachine.ports.jsRollBackAddClass.subscribe(function(addClassData) {
    var $target = jQuery(`[data-replaced-with-${addClassData.label}=true]`);


    $target.removeClass(addClassData.class);
    $target.removeAttr(`data-replaced-with-${addClassData.label}`);
    $target.removeClass("eroded");
  });

  //
  // jsCheckSilentAutoplay : elm port
  //
  erosionMachine.ports.jsCheckAutoplayStatus.subscribe(function() {
    const log = _.partial(console.log, '[check-silent-autoplay]');

    canAutoPlay.video()
      .then(({result}) => {
        log(`can be played with sound: ${result}`);
        erosionMachine.ports.jsSetAutoplayStatus.send(!result);
      });
  });

  //
  //
  // splash screen subs
  //
  //

  //
  // show splash screen
  //
  erosionMachine.ports.jsShowSplashScreen.subscribe(function() {
    const log = _.partial(console.log, '[show-splashscreen]');

    showSplashScreen({onIsShown: erosionMachine.ports.jsSplashScreenIsShown.send,
                      onClose: erosionMachine.ports.jsSplashScreenClosed.send});
  });

  //
  // grow splash screen
  //
  erosionMachine.ports.jsGrowSplashScreen.subscribe(function( msg) {
    const log = _.partial(console.log, '[grow-splashscreen]');

    const $oldText = jQuery("#op-erosion-splash-screen h1.active");
    const $newText = jQuery("#op-erosion-splash-screen h1:not(.active)");


    $oldText.removeClass("active");
    $newText.addClass("active");

    $newText.text(msg);

    const textWidth = _.max([$oldText.width(), $newText.width()]);
    const textHeight = _.max([$oldText.height(), $newText.height()]);

    jQuery("#op-erosion-splash-screen")
      .height(function(i, curHeight) {
        const h = _.max([curHeight, textHeight]);

        return _.clamp(h + _.random(0, 10), 0, jQuery(window).height());
      })
      .width(function(i, curWidth) {
        const w = _.max([curWidth, textWidth]);

        return _.clamp(w + _.random(0, 10), 0, jQuery(window).width());
      })
      .css("top", function(i, curTop) {
        const curHeight = jQuery(this).height();
        var d = _.random(-100, 100);

        var top = _.chain(curTop).replace("px", "").toNumber().value() + d;

        return _.clamp(top, 0, jQuery(window).height() - curHeight);

      })
      .css("left", function(i, curLeft) {
        const curWidth = jQuery(this).width();
        var d = _.random(-100, 100);

        var left = _.chain(curLeft).replace("px", "").toNumber().value() + d; // _.sample([d, (-1) * d]);

        return `${_.clamp(left, 0, jQuery(window).width() - curWidth)}px`;
      });

  });

  //
  // parse language of the page
  //
  erosionMachine.ports.jsAskLanguage.subscribe(function() {
    const log = _.partial(console.log, '[as-language]');

    const isRuByHeaders = jQuery("body:lang(ru)").length != 0;
    const isEnByHeaders = jQuery("body:lang(en)").add("body:lang(en-us)").length != 0;
    const isRuByUrl = /\/ru\//.test(window.location.href);
    const isEnByUrl = /\/en\//.test(window.location.href);

    log("ru by headers: ", isRuByHeaders);
    log("ru by url:", isRuByUrl);

    log("en by headers: ", isEnByHeaders);
    log("en by url:", isEnByUrl);

    // malformed garage digital web-page
    if (isRuByHeaders && isEnByUrl) {
      log("lang is ", "en");
      erosionMachine.ports.jsGotLanguage.send("en");
      return;
    }

    if (isRuByHeaders || isRuByUrl) {
      log("lang is ", "ru");
      erosionMachine.ports.jsGotLanguage.send("ru");
      return;
    }

    if (isEnByHeaders ||isEnByUrl) {
      log("lang is ", "en");
      erosionMachine.ports.jsGotLanguage.send("en");
      return;
    }

    // default lang
      log("unknown lang. set to default:", "en");
      erosionMachine.ports.jsGotLanguage.send("en");
  });

  jQuery(window).on("touchmove", function() {
    erosionMachine.ports.jsTouchMove.send("touchmove");
  });

  console.log("[runErosionMachine] done");
}

if ( document.readyState === "complete" || (document.readyState !== "loading" && !document.documentElement.doScroll) ) {
  runErosionMachine();
} else {
  document.addEventListener('readystatechange', event => {
    if (event.target.readyState === 'complete') {
      runErosionMachine();
    }
  });
}
