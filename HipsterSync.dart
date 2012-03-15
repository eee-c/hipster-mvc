#library('Sync layer for HipsterMVC');

#import('dart:html');
#import('dart:json');

class HipsterSync {
  // private class variable to hold an application injected sync behavior
  static var _injected_sync;

  // setter for the injected sync behavior
  static set sync(fn) {
    _injected_sync = fn;
  }

  // delete the injected sync behavior
  static useDefaultSync() {
    _injected_sync = null;
  }

  // static method for HipsterModel and HipsterCollection to invoke -- will
  // forward the call to the appropriate behavior (injected or default)
  static Future<Dynamic> call(method, model) {
    if (_injected_sync == null) {
      return _defaultSync(method, model);
    }
    else {
      // TODO check for null future returned from _injected_sync
      return _injected_sync(method, model);
    }
  }

  static Map _methodMap = const {
    'create': 'post',
    'update': 'put',
    'read': 'get'
  };

  // default sync behavior
  static Future _defaultSync(_method, model) {
    String method = _method.toLowerCase(),
           verb   = _methodMap.containsKey(method) ?
                      _methodMap[method] : method;

    var request = new XMLHttpRequest(),
        completer = new Completer();

    request.
      on.
      load.
      add((event) {
        var req = event.target;

        if (req.status > 299) {
          completer.
            completeException("That ain't gonna work: ${req.status}");
        }
        else {
          var json = JSON.parse(req.responseText);
          completer.complete(json);
        }
      });

    request.open(verb, model.url, true);

    // POST and PUT HTTP request bodies if necessary
    if (verb == 'post' || verb == 'put') {
      request.setRequestHeader('Content-type', 'application/json');
      request.send(JSON.stringify(model.attributes));
    }
    else {
      request.send();
    }

    return completer.future;
  }
}
