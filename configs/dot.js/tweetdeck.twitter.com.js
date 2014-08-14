var blocker = function(event) {
  if (event.altKey) {
    event.stopImmediatePropagation();
  }
};
['keyup', 'keydown', 'keypress'].map(function(event_type) {
  // Setting useCapture to true ensures the document receives the event
  // first (during the capture phase, when handlers are run from the
  // outside in).  Most event handlers use bubbling, which runs
  // inside-out.  Even if the page did this same thing, this script runs
  // before there's any DOM at all, so we're guaranteed (I hope) to be
  // the first listener, and stopImmediatePropagation will block any
  // other listeners even for the same event on the same element.
  document.addEventListener(event_type, blocker, true);
});
