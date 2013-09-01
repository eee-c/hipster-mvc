part of hipster_mvc_test;

class WidgetsModel extends HipsterModel {
  WidgetsModel(attributes): super(attributes);
  String get urlRoot => Kruk.widgets_url;
}


hipster_model_tests() {
  group("HipsterModel", (){
    var id;

    setUp((){
      return new WidgetsModel({'foo': 42}).save().
        then((widget) {
          id = widget.id;
        });
    });

    test("can serialize attributes for storage", (){
      HttpRequest.
        getString('${Kruk.widgets_url}/${id}').
        then(expectAsync1((responseText) {
          expect(
            responseText,
            contains('"foo":42')
          );
        }));
    });
  });
}
