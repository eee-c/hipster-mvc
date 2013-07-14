import 'package:hop/hop.dart';

import '../test/test_server.dart' as TestServer;
import 'dart:async';
import 'dart:io';

void main() {
  addAsyncTask('test_server-start', _startTestServer);
  addAsyncTask('test_server-stop', _stopTestServer);
  runHop();
}

Future<bool> _startTestServer(TaskContext content) {
  var started = new Completer();

  Process.
    start('dart', ['test/test_server.dart']).
    then((process) {
      new File('test_server.pid')
        ..writeAsStringSync('${process.pid}');
      started.complete(true);
    });

  return started.future;
}

Future<bool> _stopTestServer(TaskContext context) {
  var killed = new Completer();

  var pid_file = new File('test_server.pid');
  var pid = pid_file.readAsStringSync();
  pid_file.deleteSync();

  Process.
    run('kill', [pid]).
    then((_)=> killed.complete(true));

  return killed.future;
}
