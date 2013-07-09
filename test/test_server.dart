import 'dart:io';
import 'dart:json' as JSON;

import 'package:dirty/dirty.dart';
import 'package:uuid/uuid.dart';

Uuid uuid = new Uuid();
Dirty db = new Dirty('test.db');

main() {
  var port = Platform.environment['PORT'] == null ?
    31337 : int.parse(Platform.environment['PORT']);

  HttpServer.bind('127.0.0.1', port).then((app) {

    app.listen((HttpRequest req) {
      if (req.uri.path.startsWith('/widgets')) {
        handleWidgets(req);
        return;
      }

      defaultResponse(req);
    });

    print('Server started on port: ${port}');
  });
}

handleWidgets(req) {
  var r = new RegExp(r"/widgets/([-\w\d]+)");
  var id_path = r.firstMatch(req.uri.path),
      id = (id_path == null) ? null : id_path[1];

  if (req.method == 'POST') return createWidget(req);
  if (req.method == 'GET' && id != null) return readWidget(id, req);
  if (req.method == 'PUT' && id != null) return updateWidget(id, req);
  if (req.method == 'DELETE' && id != null) return deleteWidget(id, req);

  notFoundResponse(req);
}

createWidget(req) {
  HttpResponse res = req.response;

  req.toList().then((list) {
    var post_data = new String.fromCharCodes(list[0]);
    var widget = JSON.parse(post_data);
    widget['id'] = uuid.v1();

    db[widget['id']] = widget;

    res.statusCode = 201;
    res.headers.contentType =
      new ContentType("application", "json", charset: "utf-8");

    res.write(JSON.stringify(widget));
    res.close();
  });
}

readWidget(id, req) {
  HttpResponse res = req.response;

  if (db[id] == null) return notFoundResponse(req);

  res.headers.contentType =
    new ContentType("application", "json", charset: "utf-8");

  res.write(JSON.stringify(db[id]));
  res.close();
}

updateWidget(id, req) {
  HttpResponse res = req.response;

  if (!db.containsKey(id)) return notFoundResponse(req);

  req.
    toList().
    then((list) {
      var data = list.expand((i)=>i),
          body = new String.fromCharCodes(data),
          widget = db[id] = JSON.parse(body);

      res.statusCode = HttpStatus.OK;
      res.headers.contentType =
        new ContentType("application", "json", charset: "utf-8");

      res.write(JSON.stringify(widget));
      res.close();
    });
}

deleteWidget(id, req) {
  if (!db.containsKey(id)) return notFoundResponse(req);

  db.remove(id);

  HttpResponse res = req.response;
  res.statusCode = HttpStatus.NO_CONTENT;
  res.close();
}

notFoundResponse(req) {
  HttpResponse res = req.response;

  print('[404] ${req.method} ${req.uri.path}');

  res.statusCode = HttpStatus.NOT_FOUND;
  res.close();
}

defaultResponse(req) {
  req.response.write(JSON.stringify({'foo': 1}));
  req.response.close();
}
