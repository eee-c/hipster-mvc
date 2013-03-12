import 'package:unittest/unittest.dart';

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
}
