import 'dart:async';
import 'dart:convert';
import 'package:test/test.dart';

import 'package:flutter_wills/flutter_wills.dart';

mockAsyncThrowException() {
  Completer c = new Completer();
  new Timer(const Duration(seconds: 2), () {
    c.completeError(new Exception('Async Action'));
  });
  return c.future;
}

mockAsyncRequest() {
  Completer c = new Completer();
  new Timer(const Duration(seconds: 2), () {
    c.complete(JSON.encode({'body': 'this is content'}));
    print('complete a request');
  });
  return c.future;
}



class TestAsyncAction extends WillsRunLastAction<Store, String> {

  @override
  Stream exec() async* {
    for(int i = 0; i < 3; i++) {
      yield await mockAsyncThrowException();
    }
  }

}


main() {
  test('test async action', () async {
    Store store = new Store();
    var result;
    try {
//      new Timer(const Duration(seconds: 4), () {
//        print('dispatch annother async action');
//        store.dispatch(new TestAsyncAction());
//      });
      result = await store.dispatch(new TestAsyncAction());
    } on WillsActionInterruptException catch(err) {
      print(err);
    } catch(err) {
      print('common catch: $err');
    }
    print(result);
  });
}