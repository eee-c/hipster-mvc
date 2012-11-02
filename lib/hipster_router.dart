#library('hipster_router');

#import("dart:html");

#import("hipster_history.dart");

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
  List get routes() => [];

  _initializeRoutes() {
    routes.forEach((route) {
      HipsterHistory.route(_routeToRegExp(route[0]), (fragment) {
        Match params = _routeToRegExp(route[0]).firstMatch(fragment);
        String event_name = (route.length == 3) ? "route:${route[2]}" : "default";
        if (params.groupCount() == 0) {
          route[1]();
          this.on[event_name].dispatch();
        }
        else if (params.groupCount() == 1) {
          route[1](params[1]);
          this.on[event_name].dispatch(params[1]);
        }
        else if (params.groupCount() == 2) {
          route[1](params[1], params[2]);
          this.on[event_name].dispatch(params[1], params[2]);
        }
        else if (params.groupCount() == 3) {
          route[1](params[1], params[2], params[3]);
          this.on[event_name].dispatch(params[1], params[2], params[3]);
        }
        else {
          throw new WrongArgumentCountException();
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
  HashMap<String,RouterEventList> listener;
  RouterEvents() {
    listener = {};
  }

  RouterEventList operator [](String type) {
    listener.putIfAbsent(type, _buildListenerList);
    return listener[type];
  }

  _buildListenerList() => new RouterEventList();
}

class RouterEventList implements EventListenerList {
  List listeners;

  RouterEventList() {
    listeners = [];
  }

  RouterEventList add(EventListener handler, [bool useCapture]) {
    listeners.add(handler);
    return this;
  }

  bool dispatch(RouterEvent event) {
    listeners.forEach((fn) {fn(event);});
    return true;
  }
}
class RouterEvent implements Event {}
