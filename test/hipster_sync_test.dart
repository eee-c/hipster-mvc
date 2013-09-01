part of hipster_mvc_test;

class FakeModel {
  String url = Kruk.widgets_url;
  HashMap attributes;
}

hipster_sync_tests() {
  group("Hipster Sync", (){
    tearDown(()=> Kruk.deleteAll());

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
      var id;
      setUp(() {
        return Kruk.
          create('{"foo": 42}').
          then((res) {
            id = JSON.decode(res.responseText)['id'];
          });
      });

      test("it can parse responses", (){
        var model = new FakeModel()
          ..url = '${Kruk.widgets_url}/${id}';

        HipsterSync.
          call('get', model).
          then(
            expectAsync1((response) {
              expect(response, containsPair('foo', 42));
            })
          );
      });
    });

    group("HTTP post", (){
      test("it can POST new records", (){
        var model = new FakeModel()
          ..attributes = {'test': 42};

        HipsterSync.
          call('create', model).
          then(
            expectAsync1((response) {
              expect(response, containsPair('test', 42));
            })
          );
      });
    });

    group('(w/ a pre-existing record)', (){
      var model, model_id;

      setUp((){
        var completer = new Completer();

        model = new FakeModel()
          ..attributes = {'test': 1};

        HipsterSync.
          call('create', model).
          then((rec) {
            model_id = rec['id'];
            completer.complete();
          });

        return completer.future;
      });

      test("HTTP PUT: can update existing records", (){
        model
          ..url = 'http://localhost:31337/widgets/${model_id}'
          ..attributes = {'test': 42};

        HipsterSync.
          call('update', model).
          then(
            expectAsync1((response) {
              expect(response, containsPair('test', 42));
            })
          );
      });

      group("HTTP DELETE:", (){
        setUp((){
          model.url = 'http://localhost:31337/widgets/${model_id}';
          return HipsterSync.call('delete', model);
        });

        test("can remove the record from the store", (){
          HipsterSync.
            call('read', model).
            catchError(
              expectAsync1((error) {
                expect(error, "That ain't gonna work: 404");
              })
            );
        });
      });
    });

    group('(w/ multiple pre-existing records)', (){
      setUp((){
        var model1 = new FakeModel()
          ..attributes = {'test': 1};

        var model2 = new FakeModel()
          ..attributes = {'test': 2};

        return Future.wait([
          HipsterSync.call('create', model1),
          HipsterSync.call('create', model2)
        ]);
      });

      test("can retrieve a collection of records", (){
        var collection = new FakeModel();

        HipsterSync.call('read', collection).
          then(
            expectAsync1((response) {
              expect(response.length, 2);
            })
          );
      });
    });
  });

}
