import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
// import _ from 'lodash';
var _ = require("lodash");
var jQuery = require("jquery");

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
  const log = _.partial(console.log, `[getTarget`);

  // deepest the most of time
  // let findFn = _.chain(["deepest", "deepest", "deepest", "find"]).shuffle().head().value();

  // log("using", findFn);

  // TODO: tell elm if there is not any elements to erode
  // TODO: do not erode erosion elements added by jsErode func
  let q = jQuery("* :not(.eroded)");


  return q
    .filter(function() {
      return !isErodedBranch(this);
    })
    .filter(function() {
      return jQuery(this).visible(true, true);
    })
    .random();
};

//
// jsErode : elm port
//
function erode(el) {
  const log = _.partial(console.log, `[erode/${el.id}]`);
  const error = _.partial(console.error, `[erode/${el.id}]`);
  log('element', el);

  var target = getTarget();

  if (target.length == 0) {
    error("there are no targets");
    throw "there are no targets";
  }

  // using label because ids are unique for frames but we need to roll back multipe frames when we know labels only
  // FIXME: make this process more transparent
  jQuery(target).attr("data-replaced-with", el.label);

  jQuery(target).addClass("eroded");

  log('eroded element', jQuery(document).find(`article [data-replaced-with='${el.label}']`));

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
//
function createBaseErosionElement(eType, data) {
  let e = document.createElement(eType);

  e.id = _.get(data, 'id', _.uniqueId());
  e.classList = _.get(data, 'class', '');
  e.label = _.get(data, 'label', '');
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

    log('data', videoData);

    let e = createBaseErosionElement('video', videoData);

    e.loop = _.get(videoData, 'loop', 'false');
    e.preload = 'auto';
    e.crossOrigin = 'anonymous';

    let sourceElement = document.createElement('source');
    sourceElement.src = _.get(videoData, 'urlMP4', '');
    sourceElement.type = 'video/mp4';
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
      erode(e);
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

    log('data', imageData);

    let e = createBaseErosionElement('img', imageData);
    e.src = _.get(imageData, 'src', '');

    try {
      erode(e);
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

    log('data', textData);

    let e = createBaseErosionElement('span', textData);
    e.textContent = textData.text;

    try {
      erode(e);
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
    log('data', addClassData);

    var target = jQuery(`#${addClassData.id}`);

    target.addClass(addClassData.class);

    if (target.length == 0) {
      error("no target for " + addClassData.id);
    }
  });


  //
  // jsRollBack : elm port
  //
  erosionMachine.ports.jsRollBack.subscribe(function(erodedIds) {
    const log = _.partial(console.log, '[roll-back]');

    log('ids to roll back', erodedIds);

    // remove subtitles
    jQuery(".subtitle-box").remove();

    _.each(erodedIds, function(eId) {
      jQuery(`.${eId}`).remove();

      const e = jQuery(`[data-replaced-with='${eId}']`);
      e.removeClass("eroded");
      e.removeAttr("data-replaced-with");
      e.show();
    });
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
