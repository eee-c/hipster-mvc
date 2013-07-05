library hipster_mvc_test;

import 'package:unittest/unittest.dart';
import 'dart:html';
import 'dart:async';

import 'package:hipster_mvc/hipster_events.dart';
import 'package:hipster_mvc/hipster_sync.dart';

part 'hipster_events_test.dart';
part 'hipster_sync_test.dart';

main(){
  hipster_events_tests();
  hipster_sync_tests();

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
