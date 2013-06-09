library hipster_history;

import 'dart:html';

class HipsterHistory {
  static List _routes;

  static get routes {
    if (_routes == null) _routes = [];
    return _routes;
  }

  static route(route, fn) {
    routes.add([route, fn]);
  }

  static startHistory() {
    window.onPopState.listen(_checkUrl);
  }

  static _checkUrl(_) {
    var fragment = window.location.hash.replaceFirst('#', '');

    var matching_handlers = routes.
      filter((r) => r[0].hasMatch(fragment));

    if (matching_handlers.isEmpty()) return;

    var handler = matching_handlers[0];
    handler[1](fragment);
  }
}
