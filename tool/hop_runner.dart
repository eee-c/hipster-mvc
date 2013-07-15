import 'package:hop/hop.dart';

import '../test/test_server.dart' as TestServer;
import 'dart:async';
import 'dart:io';

void main() {
  addAsyncTask('tests-run', _runTests);
  addAsyncTask('test_server-start', _startTestServer);
  addAsyncTask('test_server-stop', _stopTestServer);
  addSyncTask('test_database-delete', _deleteTestDb);
  runHop();
}


Future<bool> _runTests(TaskContext content) {
  var tests = new Completer();

  Process.
    run('content_shell', ['--dump-render-tree', 'test/index.html']).
    then((res) {
      var lines = res.stdout.split("\n");
      print(
        lines.
          where((line)=> line.contains('CONSOLE')).
          join("\n")
      );
      tests.complete(res.stdout.contains('unittest-suite-success'));
    });

  return tests.future;
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

bool _deleteTestDb(TaskContext context) {
  var db = new File('test/test.db');
  if (!db.existsSync()) return true;

  db.deleteSync();
  return true;
}
