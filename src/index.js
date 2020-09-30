import './main.css';
import { Elm } from './ErosionMachine.elm';
import * as serviceWorker from './serviceWorker';
// import _ from 'lodash';
var _ = require("lodash");

import * as _invoke from "lodash.invoke";
import * as jQuery from 'jquery';
// import * as cljs from 'bundle';
// import * as erosionMachine from "./cljs-bundle/index.js";

const erosionMachine = Elm.ErosionMachine.init({
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
jQuery(document).ready(function(){

   function getTarget() {
     let findFn = _.chain(["deepest", "deepest", "find", "find"]).shuffle().head().value();

     // TODO: tell elm if there is not any elements to erode
     // TODO: do not erode erosion elements added by jsErode func
     return _.invoke(jQuery(document), findFn, "article *:not(.eroded)").random();
  };

  //
  // jsErode : elm port
  //
  // FIXME: eId - String
  erosionMachine.ports.jsErode.subscribe(function(eId) {
    const log = _.partial(console.log, '[erode]');

    log('eroion id', eId);

    const e = document.createElement("span");
    e.innerHTML = eId;
    e.id = eId;
    jQuery(e).addClass("eroded");

    var target = getTarget();

    jQuery(target).attr("data-replaced-with", eId);

    jQuery(target).addClass("eroded");
    jQuery(e).insertAfter(target);
    jQuery(target).hide();

    log('eroded element', jQuery(document).find(`[data-replaced-with='${eId}']`));

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

});
