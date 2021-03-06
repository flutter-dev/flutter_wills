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
  Stream<String> exec() async* {
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
      result = await store.dispatch(new TestAsyncAction());
    } on WillsActionInterruptException catch(err) {
      print(err);
    } catch(err) {
      print('common catch: $err');
    }
    print(result);
  });
}