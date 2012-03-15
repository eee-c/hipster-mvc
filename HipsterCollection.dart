#library('Base class for Collections');

#import('dart:html');
#import('dart:json');

#import('HipsterModel.dart');
#import('HipsterSync.dart');

class HipsterCollection implements Collection {
  CollectionEvents on;
  List<HipsterModel> models;
  Map<String,Map> data;

  HipsterCollection() {
    on = new CollectionEvents();
    models = <HipsterModel>[];
  }

  abstract HipsterModel modelMaker(attrs);
  abstract String get url();

  // Be List-like
  void forEach(fn) {
    models.forEach(fn);
  }

  int get length() => models.length;

  // Be Backbone like
  operator [](id) {
    var ret;
    forEach((model) {
      if (model['id'] == id) ret = model;
    });
    return ret;
  }

  fetch() {
    HipsterSync.
      call('read', this).
      then((list) {
        list.forEach((attrs) {
          var new_model = modelMaker(attrs);
          new_model.collection = this;
          models.add(new_model);
        });

        on.load.dispatch(new CollectionEvent('load', this));
      });
  }

  create(attrs) {
    Future after_save = _buildModel(attrs).save();

    after_save.
      then((saved_model) {
        this.add(saved_model);
      });

    after_save.
      handleException(bool (e) {
        print("Exception handled: ${e}");
        return true;
      });
  }

  add(model) {
    models.add(model);
    on.
      insert.
      dispatch(new CollectionEvent('add', this, model:model));
  }

  _buildModel(attrs) {
    var new_model = modelMaker(attrs);
    new_model.collection = this;
    return new_model;
  }
}

class CollectionEvents implements Events {
  CollectionEventList load_listeners, insert_listeners;

  CollectionEvents() {
    load_listeners = new CollectionEventList();
    insert_listeners = new CollectionEventList();
  }

  CollectionEventList get load() => load_listeners;
  CollectionEventList get insert() => insert_listeners;
}

class CollectionEventList implements EventListenerList {
  List listeners;

  CollectionEventList() {
    listeners = [];
  }

  CollectionEventList add(fn) {
    listeners.add(fn);
    return this;
  }

  bool dispatch(CollectionEvent event) {
    listeners.forEach((fn) {fn(event);});
    return true;
  }
}

class CollectionEvent implements Event {
  String _type;
  HipsterCollection collection;
  HipsterModel _model;

  CollectionEvent(this._type, this.collection, [model]) {
    _model = model;
  }

  String get type() =>_type;

  HipsterModel get model() => _model;
}
