#library('Router for MVC pages.');

#import("dart:html");

class HipsterRouter {
  RouterEvents on;

  HipsterRouter() {
    on = new RouterEvents();
    this._initializeRoutes();
  }

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

  RouterEventList add(fn) {
    listeners.add(fn);
    return this;
  }

  bool dispatch(RouterEvent event) {
    listeners.forEach((fn) {fn(event);});
    return true;
  }
}
class RouterEvent implements Event {}
