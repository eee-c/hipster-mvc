part of hipster_mvc_test;

class TestEventListenerList extends HipsterEventListenerList {}

hipster_events_tests() {
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
