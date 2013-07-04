import 'package:unittest/unittest.dart';
import 'dart:html';
import 'dart:async';

import 'package:hipster_mvc/hipster_events.dart';

class TestEventListenerList extends HipsterEventListenerList {}

main() {
  group('unsupported', () {
    // TODO: delete this (it doesn't do anything)
    test('remove', (){
      var it = new TestEventListenerList();
      expect(
        () => it.remove("foo"),
        throws
      );
    });
  });

  pollForDone(testCases);
}

pollForDone(List tests) {
  if (tests.every((t)=> t.isComplete)) {
    window.postMessage('done', window.location.href);
    return;
  }

  var wait = new Duration(milliseconds: 100);
  new Timer(wait, ()=> pollForDone(tests));
}
