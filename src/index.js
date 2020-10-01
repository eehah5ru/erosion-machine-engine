import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
// import _ from 'lodash';
var _ = require("lodash");

import * as _invoke from "lodash.invoke";
import * as jQuery from 'jquery';
// import * as cljs from 'bundle';
// import * as erosionMachine from "./cljs-bundle/index.js";

const erosionMachine = Elm.Main.init({
  node: document.getElementById('root')
});

// erosionMachine.hello_world.core.init();

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();

//
// jquery random plugin
//

jQuery.fn.random = function() {
    var randomIndex = Math.floor(Math.random() * this.length);
    return jQuery(this[randomIndex]);
};

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

//
// END OF JQUERY PLUGINS
//

function getTarget() {
  let findFn = _.chain(["deepest", "deepest", "find", "find"]).shuffle().head().value();

  // TODO: tell elm if there is not any elements to erode
  // TODO: do not erode erosion elements added by jsErode func
  return _.invoke(jQuery(document), findFn, "article *:not(.eroded)").random();
};

//
// jsErode : elm port
//
function erode(el) {
  const log = _.partial(console.log, `[erode/${el.id}]`);
  const error = _.partial(console.error, `[erode/${el.id}]`);
  log('element', el);

  var target = getTarget();

  jQuery(target).attr("data-replaced-with", el.id);

  jQuery(target).addClass("eroded");

  log('eroded element', jQuery(document).find(`article [data-replaced-with='${el.id}']`));

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

function playVideo(videoElement) {
  const log = _.partial(console.log, `[playVideo/${videoElement.id}]`);
  const error = _.partial(console.error, `[playVideo/${videoElement.id}]`);

  // videoElement.textTracks[0].oncuechange = function() {
  //   try {
  //     event.subtitleBoxEl.innerText = get(
  //       event.el,
  //       'textTracks[0].activeCues[0].text',
  //       ''
  //     )
  //   } catch (err) {
  //     console.error('💥 Error adding subtitle:', err)
  //   }
  // }
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
// stub element
//
// FIXME: remove when all ports will be implemented
function stubElement(stubData) {
  let e = document.createElement("span");

  e.id = _.get(stubData, 'id', _.uniqueId());
  e.classList = _.get(stubData, '_class', '');
  jQuery(e).addClass('eroded');
  e.innerText = _.get(stubData, 'id', '');

  return e;
}

//
//
// incoming ports
//
//

//
// show video
//
erosionMachine.ports.jsShowVideo.subscribe(function(videoData) {
  const log = _.partial(console.log, '[showVideo]');
  log('data', videoData);

  let e = document.createElement('video');
  e.id = _.get(videoData, 'id', _.uniqueId());
  e.classList = _.get(videoData, '_class', '');
  jQuery(e).addClass('eroded');
  e.loop = _.get(videoData, 'loop', 'false');
  e.preload = 'auto';
  e.crossOrigin = 'anonymous';

  let sourceElement = document.createElement('source');
  sourceElement.src = _.get(videoData, 'urlMP4', '');
  sourceElement.type = 'video/mp4';

  try {
    e.appendChild(sourceElement);
  } catch (err) {
    console.log(err);
  }

  erode(e);
  playVideo(e);
});

//
// show image
//
erosionMachine.ports.jsShowImage.subscribe(function(imageData) {
  const log = _.partial(console.log, '[showImage]');
  log('data', imageData);

  erode(stubElement(imageData));
});

//
// show text
//
erosionMachine.ports.jsShowText.subscribe(function(textData) {
  const log = _.partial(console.log, '[showText]');
  log('data', textData);

  erode(stubElement(textData));
});

//
// add class
//
// FIXME: implement actual logic!
erosionMachine.ports.jsAddClass.subscribe(function(addClassData) {
  const log = _.partial(console.log, '[addClass]');
  log('data', addClassData);

  erode(stubElement(addClassData));
});

//
// show assemblage
//
// FIXME: remove this stub function!!!
erosionMachine.ports.jsShowAssemblage.subscribe(function(aId) {
  const log = _.partial(console.log, '[showAssemblage]');
  log('id', aId);

  let data = {id: aId, class: aId};

  erode(stubElement(data));
});





//
// jsRollBack : elm port
//
erosionMachine.ports.jsRollBack.subscribe(function(erodedIds) {
  const log = _.partial(console.log, '[roll-back]');

  log('ids to roll back', erodedIds);

  _.each(erodedIds, function(eId) {
    jQuery(`#${eId}`).remove();

    const e = jQuery(`[data-replaced-with='${eId}']`);
    e.removeClass("eroded");
    e.removeAttr("data-replaced-with");
    e.show();
  });
});
