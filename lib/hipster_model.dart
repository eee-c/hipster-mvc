library hipster_model;

import 'dart:async';

import 'hipster_collection.dart';
import 'hipster_sync.dart';

/** HipsterModel encapsulates individual records in your backend datastore. At
 * its most concise, a model need only to implement the [urlRoot] method:
 *     class ComicBook extends HipsterModel {
 *       get urlRoot => '/comics';
 *     }
 */
class HipsterModel {
  /** The internal representation of the record. */
  Map attributes;

  StreamController _onSave, _onDelete;

  /** If the model is part of a collection, it will be stored here. */
  HipsterCollection collection;

  /**
   * If attributes is not supplied, it will be initalied to an empty
   * [HashMap].
   */
  HipsterModel([this.attributes]) {
    if (attributes == null) attributes = {};
    _onSave = new StreamController.broadcast();
    _onDelete = new StreamController.broadcast();
  }

  Stream get onSave => _onSave.stream;
  Stream get onDelete => _onDelete.stream;

  // TODO: better hashing function (delimited keys and values?)
  static String hash() {
    return (new DateTime.now()).hashCode.toRadixString(16);
  }

  /**
   * Convenience operator for attribute lookup:
   *
   *     var comic = new ComicBook({'title': 'Superman'});
   *     comic['title'];
   *     // => 'Superman'
   */
  operator [](attr) => attributes[attr];

  /** The ID of the record in the backend store. */
  get id => attributes['id'];

  /**
   * The URL at which creates or updates are stored. If the model has already
   * been saved to the backend, then the ID will be appended
   * (e.g. `/comics/42`).
   */
  String get url => isSaved() ?
    "$urlRoot/$id" : urlRoot;

  /**
   * The base URL for REST-like operations _without_ the trailing slash
   * (e.g. `/comics`). This is delegated to the collection if present.
   *
   * If the subclass is ever used without a collection, then the subclass is
   * required to define this:
   *     class ComicBook extends HipsterModel {
   *       get urlRoot => '/comics';
   *     }
   */
  String get urlRoot => (collection == null) ?
    "" : collection.url;

  /**
   * Returns true if the model has been _previously_ saved to the backend (not
   * if the most recent changes have been saved).
   */
  bool isSaved() => id != null;

  /**
   * Either creates or updates this record in the backend datastore. This
   * method returns a [Future] that can be used to perform subsequent actions
   * upon successful save:
   *     comic.
   *       save().
   *       then((_) { print("Yay! New comics!"); });
   */
  Future<HipsterModel> save() {
    Completer completer = new Completer();
    String operation = isSaved() ? 'update' : 'create';
    Future after_call = HipsterSync.send(operation, this);

    after_call.
      then((attrs) {
        this.attributes = attrs;
        _onSave.add(this);
        completer.complete(this);
      });

    after_call.
      catchError((e) {
        completer.completeError(e);
        return true;
      });

    return completer.future;
  }

  /**
   * Instructs the backend datastore that this recored should be deleted. Upon
   * successful removal, this method returns a [Future] that can be used to
   * perform subsequent action:
   *     comic.
   *       delete.
   *       then((_) { print("Now I am sad.") });
   */
  Future<HipsterModel> delete() {
    Completer completer = new Completer();

    HipsterSync.
      send('delete', this).
      then((attrs) {
        _onDelete.add(this);
        completer.complete(this);
      });

    return completer.future;
  }
}
