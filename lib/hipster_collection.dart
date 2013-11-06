library hipster_collection;

import 'dart:async';
import 'dart:collection';

import 'hipster_model.dart';
import 'hipster_sync.dart';

abstract class HipsterCollection extends IterableBase {
  StreamController _onLoad, _onAdd;
  List<HipsterModel> models = [];
  Map<String,Map> data;

  HipsterModel modelMaker(attrs);
  String get url;

  HipsterCollection(){
    _onLoad = new StreamController.broadcast();
    _onAdd = new StreamController.broadcast();
  }

  Stream get onLoad => _onLoad.stream;
  Stream get onAdd => _onAdd.stream;

  // Be List-like
  get iterator => models.iterator;

  // Be Backbone like
  operator [](id) {
    var ret;
    forEach((model) {
      if (model['id'] == id) ret = model;
    });
    return ret;
  }

  Future<Map> fetch() {
    return HipsterSync.
      send('read', this).
      then((list) {
        list.forEach((attrs) {
          models.add(_buildModel(attrs));
        });
        _onLoad.add(this);
      });
  }

  Future<dynamic> create(attrs) {
    return _buildModel(attrs).
      save()
      ..then((saved_model) {
          this.add(saved_model);
        })
      ..catchError((e) {
          print("Exception handled: ${e}");
          return true;
        });
  }

  add(model) {
    models.add(model);
    _onAdd.add(model);
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
