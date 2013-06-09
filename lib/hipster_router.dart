library hipster_router;

import "dart:html";
import "dart:async";
import "dart:collection";

import "hipster_history.dart";

class HipsterRouter {
  /**
   * The router exposes named events on which listeners can wait. For example,
   * if the router has a "page" route, the event will be available on the
   * 'route:page' event:
   *
   *     HipsterRouter app = new MyRouter();
   *       app.
   *         on['route:page'].
   *         add((num) {
   *           print("Routed to page: $num");
   *         });
   */
  RouterEvents on;

  /**
   * Application routers must subclass [HipsterRouter], definining at least the
   * [routes] getter:
   *
   *     class MyRouter extends HipsterRouter {
   *       List get routes() =>
   *         [
   *           ['page/:num', pageNum, 'page']
   *         ];
   *       //
   *       pageNum(num) {
   *         var el = document.query('body');
   *          el.innerHTML = _pageNumTemplate(num);
   *       }
   *     }
   *
   * Start the router by creating an instance of the routing class and by
   * telling [HipsterHistory] to start listening for pushState events:
   *
   *      HipsterRouter app = new MyRouter();
   *      HipsterHistory.startHistory();
   */
  HipsterRouter() {
    on = new RouterEvents();
    this._initializeRoutes();
  }

  /**
   * As shown in the constructor example, each route must include three values:
   *
   * * A string representation of the route, which can include placeholders (e.g. "page:num")
   * * The method to be invoked when the route is matched
   * * A string that names the event that is generated for [on].
   */
  List get routes => [];

  _initializeRoutes() {
    routes.forEach((route) {
      HipsterHistory.route(_routeToRegExp(route[0]), (fragment) {
        Match params = _routeToRegExp(route[0]).firstMatch(fragment);
        String event_name = (route.length == 3) ? "route:${route[2]}" : "default";
        if (params.groupCount == 0) {
          route[1]();
          this.on.dispatch(event_name);
        }
        else if (params.groupCount == 1) {
          route[1](params[1]);
          this.on.dispatch(event_name, params[1]);
        }
        else if (params.groupCount == 2) {
          route[1](params[1], params[2]);
          this.on.dispatch(event_name, params[1], params[2]);
        }
        else if (params.groupCount == 3) {
          route[1](params[1], params[2], params[3]);
          this.on.dispatch(event_name, params[1], params[2], params[3]);
        }
        else {
          throw new ArgumentError();
        }
      });
    });
  }

  _routeToRegExp(matcher) {
    var bits = matcher.split('/').map((chunk) {
      if (chunk.startsWith(':')) return '([^\/]+)';
      return chunk;
    });

    var regex = '';
    for (var bit in bits) {
      regex += bit;
      regex += '/';
    }
    return new RegExp(regex.substring(0, regex.length-1));
  }
}

class RouterEvents implements Events {
  HashMap<String,StreamController> listener;
  RouterEvents() {
    listener = {};
  }

  Stream operator [](String type) {
    listener.putIfAbsent(type, _buildStream);
    return listener[type].stream.asBroadcastStream();
  }

  get _buildStream => new StreamController();

  void dispatch(String type, [arg1, arg2, arg3]) {
    if (arg3 != null) listener[type].add([arg1, arg2, arg3]);
    else if (arg2 != null) listener[type].add([arg1, arg2]);
    else if (arg1 != null) listener[type].add([arg1]);
    else listener[type].add([]);
  }
}
