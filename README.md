# Hipster MVC

The MVC library for Dart, inspired by Backbone.js and used extensively in the Pragmatic Programmers book, "Dart for Hipsters".

[API Documentation](http://eee-c.github.com/hipster-mvc).

[![](https://drone.io/eee-c/HispterMVC/status.png)](https://drone.io/eee-c/HispterMVC/latest)

## Getting Started

A fully functional sample app is available at [dart-comics](https://github.com/eee-c/dart-comics).

Displaying a collection of resources is as simple as defining model, collection and collection view classes and then instantiating them:

````dart
import 'Collections.Comics.dart' as 'Collections';
import 'Views.Comics.dart' as 'Views';

main() {
  var my_comics_collection = new Collections.Comics()
    , comics_view = new Views.Comics(
        el:'#comics-list',
        collection: my_comics_collection
      );

  my_comics_collection.fetch();
}
````

If the backend exposes a REST-like API, your collection and model classes can be very brief.

### A Collection Example

````dart
library comics_collection;

import 'package:hipster-mvc/HipsterCollection.dart';

import 'Models.ComicBook.dart';

class Comics extends HipsterCollection {
  get url => '/comics';
  modelMaker(attrs) => new ComicBook(attrs);
}
````

### A Model Example

````dart
library comic_book;

import 'package:hipster-mvc/HipsterModel.dart';

class ComicBook extends HipsterModel {
  ComicBook(attributes) : super(attributes);
}
````

## History

 * `0.2.0` — New `import` / `library` support. Method signature for `EventListenerList#add` has changed again.
 * `0.1.0` — Initial release, ready for Dart M1.

## More information

This grew out of a series of blog entries at: http://japhr.blogspot.com/search/label/dart

## License

This software is licensed under the MIT License.

Copyright Chris Strom, 2013.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the
following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
USE OR OTHER DEALINGS IN THE SOFTWARE.
