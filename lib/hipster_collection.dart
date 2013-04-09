library hipster_collection;

import 'dart:async';

import 'hipster_model.dart';
import 'hipster_sync.dart';
import 'hipster_events.dart';

abstract class HipsterCollection implements Collection {
  CollectionEvents on = new CollectionEvents();
  List<HipsterModel> models = [];
  Map<String,Map> data;

  HipsterModel modelMaker(attrs);
  String get url;

  // Be List-like
  void forEach(fn) {
    models.forEach(fn);
  }

  get iterator => models.iterator;

  bool get isEmpty => models.isEmpty;
  map(fn) => models.map(fn);
  contains(element) => models.contains(element);
  fold(initialValue, fn) => models.fold(initialValue, fn);
  every(fn) => models.every(fn);

  int get length => models.length;

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
          models.add(_buildModel(attrs));
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
      catchError((e) {
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
    // Give the factory a chance to define attributes on the model, if it does
    // not, explicitly set them.
    if (new_model.attributes.isEmpty) new_model.attributes = attrs;
    new_model.collection = this;
    return new_model;
  }
}

class CollectionEvent extends HipsterEvent {
  String type;
  HipsterCollection collection;
  HipsterModel model;

  CollectionEvent(this.type, this.collection, {this.model});
}

class CollectionEvents extends HipsterEvents {
  var load_listeners  = new CollectionEventListenerList(),
      insert_listeners = new CollectionEventListenerList();

  CollectionEventListenerList get load => load_listeners;
  CollectionEventListenerList get insert => insert_listeners;

  operator [](String type) {
    if (type == 'load') return this.load;
    if (type == 'insert') return this.insert;
    return new CollectionEventListenerList();
  }
}

class CollectionEventListenerList extends HipsterEventListenerList {}
