import 'dart:async';
import 'dart:collection';

import 'package:flutter_wills/src/core.dart';
import 'package:flutter_wills/src/errors.dart';

abstract class WillsAction<S extends Store<Reactive>, T> {

  Completer<T> _resultCompleter = new Completer<T>();

  S _store;

  S get $store => _store;

  Future<T> get result => _resultCompleter.future;


  Future<T> call() {
    StreamSubscription ss;
    var result;
    ss = exec().handleError((err) {
      _resultCompleter.completeError(err);
      ss.cancel();
    }).listen(null);
    ss..onData((data)=> result = data)..onDone(() {
      _resultCompleter.complete(result);
    });
    return result;
  }

  Stream exec() async* {}
}

abstract class WillsRunLastAction<S extends Store<Reactive>, T> extends WillsAction<S, T> {

  static int execId = 0;

  int _execId;

  @override
  call() {
    _execId = ++execId;
    dynamic result;
    StreamSubscription ss;
    ss = exec().handleError((err) {
      _resultCompleter.completeError(err);
      ss.cancel();
    }).listen(null);
    ss..onData((data) {
      result = data;
      if(_execId != execId) {
        ss.cancel();
        _resultCompleter.completeError(const WillsActionInterruptException());
      }
    })..onDone(() {
      if(!_resultCompleter.isCompleted) {
        _resultCompleter.complete(result);
      }
      ss.cancel();
    });
  }

}

abstract class WillsRunUniqueAction<S extends Store<Reactive>, T> extends WillsAction<S, T> {
  static WillsRunUniqueAction active;

  call() {
    if(active != null) {
      _resultCompleter.completeError(new WillsActionExistsException());
    } else {
      super.call();
    }
  }
}

abstract class WillsRunQueueAction<S extends Store<Reactive>, T> extends WillsAction<S, T> {

  static Queue<WillsRunQueueAction> queue = new Queue();

  static WillsRunQueueAction active;

  _next() {
    active = null;
    queue.removeFirst()?.call();
  }

  call() {
    if(active != null) {
      queue.addLast(this);
      return null;
    }
    active = this;
    var result;
    StreamSubscription ss;
    ss = exec().handleError((err) {
      _resultCompleter.completeError(err);
      ss.cancel();
      _next();
    }).listen(null);
    ss..onData((data) {
      result = data;
    })..onDone(() {
      _resultCompleter.complete(result);
      _next();
    });
  }
}

abstract class WillsMutation<S extends Store<Reactive>> {
  S _store;

  S get $store => _store;

  call() {
    exec();
  }

  exec();
}

class Store<State extends Reactive> {

  final State state;

  Store({this.state});

  Future dispatch(WillsAction action) async {
    action._store = this;
    action();
    return action.result;
  }

  commit(WillsMutation mutation) {
    mutation._store = this;
    mutation();
  }

}