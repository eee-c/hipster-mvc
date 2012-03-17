#library('Base class for Models');

#import('dart:html');
#import('dart:json');

#import('HipsterSync.dart');

class HipsterModel implements Hashable {
  Map attributes;
  ModelEvents on;
  Collection collection;

  HipsterModel(this.attributes, [this.collection]) {
    on = new ModelEvents();
  }

  static String hash() {
    return (new Date.now()).value.hashCode().toRadixString(16);
  }

  operator [](attr) => attributes[attr];

  get id() => attributes['id'];

  get url() => isSaved() ?
      urlRoot : "$urlRoot/$id";

  get urlRoot() => (collection == null) ?
    "" : collection.url;

  bool isSaved() => id == null;

  // TODO: update
  Future<HipsterModel> save() {
    Completer completer = new Completer();

    Future after_call = HipsterSync.call('create', this);

    after_call.
      then((attrs) {
        this.attributes = attrs;
        on.load.dispatch(new ModelEvent('save', this));
        completer.complete(this);
      });

    after_call.
      handleException((e) {
        completer.completeException(e);
        return true;
      });

    return completer.future;
  }

  Future<HipsterModel> delete() {
    Completer completer = new Completer();

    HipsterSync.
      call('delete', this).
      then((attrs) {
        var event = new ModelEvent('delete', this);
        on.delete.dispatch(event);

        completer.complete(this);
      });

    return completer.future;
  }

}

class ModelEvent implements Event {
  var type, model;
  ModelEvent(this.type, this.model);
}

class ModelEvents implements Events {
  var load_list;
  var save_list;
  var delete_list;

  ModelEvents() {
    load_list = new ModelEventList();
    save_list = new ModelEventList();
    delete_list = new ModelEventList();
  }

  get load() { return load_list; }
  get save() { return save_list; }
  get delete() { return delete_list; }
}

class ModelEventList implements EventListenerList {
  var listeners;

  ModelEventList() {
    listeners = [];
  }

  add(fn) {
    listeners.add(fn);
  }

  bool dispatch(Event event) {
    listeners.forEach((fn) {fn(event);});
    return true;
  }
}
