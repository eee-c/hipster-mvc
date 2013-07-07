part of hipster_mvc_test;

class FakeModel {
  String url = 'http://localhost:31337/test';
  HashMap attributes;
}

hipster_sync_tests() {
  group("Hipster Sync", (){
    test("can parse regular JSON", (){
      expect(
        HipsterSync.parseJson('{"foo": 1}'),
        {'foo': 1}
      );
    });
    test("can parse empty responses", (){
      expect(
        HipsterSync.parseJson(''),
        {}
      );
    });

    group("HTTP get", (){
      test("it can parse responses", (){
        _test(response) {
          expect(response, {'foo': 1});
        }

        var model = new FakeModel();
        HipsterSync.call('get', model).then(expectAsync1(_test));
      });
    });

    group("HTTP post", (){
      test("it can POST new records", (){
        _test(response) {
          expect(response, containsPair('test', 42));
        }

        var model = new FakeModel();
        model.url = 'http://localhost:31337/widgets';
        model.attributes = {'test': 42};

        HipsterSync.call('create', model).then(expectAsync1(_test));
      });
    });
  });
}
