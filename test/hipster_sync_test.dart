part of hipster_mvc_test;

class FakeModel {
  String url = 'http://localhost:31337/test';
  HashMap attributes;
}

hipster_sync_tests() {
  group("Hipster Sync", (){
    // tearDown(() {
    //   var model = new FakeModel()
    //     ..url = 'http://localhost:31337/widgets/ALL';
    //   HipsterSync.call('delete', model);
    // });

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

    solo_group("HTTP get", (){
      var server;
      setUp(() {
        server = js.context.sinon.fakeServer.create();
        // server.respondWith(
        //   '{ "id": 12, "comment": "Hey there" }'
        // );
        var cb = new js.Callback.once((req) {
          req.respond(200, [], '{ "id": 12, "comment": "Hey there" }');
        });

        server.respondWith(cb);
      });

      test("it can parse responses", (){
        var request = new HttpRequest();

        request.
          onLoad.
          listen(expectAsync1((event) {
            HttpRequest req = event.target;

            var response = JSON.parse(req.responseText);
            expect(response, containsPair('comment', 'Hey there'));
            }));
        request.open('GET', '/test');



        // var model = new FakeModel()
        //   ..url = '/test';
        // HipsterSync.
        //   call('get', model).
        //   then(
        //     expectAsync1((response) {
        //       expect(response, containsPair('comment', 'Hey there'));
        //     })
        //   );
        server.respond();
      });
    });

    group("HTTP post", (){
      test("it can POST new records", (){
        var model = new FakeModel();
        model.url = 'http://localhost:31337/widgets';
        model.attributes = {'test': 42};

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
          ..url = 'http://localhost:31337/widgets'
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
          ..url = 'http://localhost:31337/widgets'
          ..attributes = {'test': 1};

        var model2 = new FakeModel()
          ..url = 'http://localhost:31337/widgets'
          ..attributes = {'test': 2};

        return Future.wait([
          HipsterSync.call('create', model1),
          HipsterSync.call('create', model2)
        ]);
      });

      test("can retrieve a collection of records", (){
        var collection = new FakeModel()
          ..url = 'http://localhost:31337/widgets';

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
