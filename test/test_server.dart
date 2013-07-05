import 'dart:io';
import 'dart:json' as JSON;

main() {
  var port = Platform.environment['PORT'] == null ?
    31337 : int.parse(Platform.environment['PORT']);

  HttpServer.bind('127.0.0.1', port).then((app) {

    app.listen((HttpRequest req) {
      req.response.write(JSON.stringify({'foo': 1}));
      req.response.close();
    });

    print('Server started on port: ${port}');
  });
}
