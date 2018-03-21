import 'package:flutter/widgets.dart';
import 'package:flutter_wills/src/store.dart';
import 'package:meta/meta.dart';
import 'package:flutter_wills/src/core.dart';

class RenderWatcher extends Watcher {
  State state;

  void _bind(State s) {
    state = s;
  }

  @override
  void run() {
    //ignore: INVALID_USE_OF_PROTECTED_MEMBER
    state.setState(() {});
  }

  void _unbind(State s) {
    state = null;
    clear();
  }
}

typedef ObserverFunc();

class UserWatcher extends Watcher {

  ObserverFunc _func;

  UserWatcher(this._func);

  @override
  void run() {
    this._func();
  }

}


class ReactiveProp<T> extends Object with Reactive {

  T _val;

  ReactiveProp([this._val]);

  T get self {
    $observe('self');
    return _val;
  }

  set self(T _self) {
    _val = _self;
    $notify('self');
  }

}

class WillsProvider extends InheritedWidget {

  final Store store;

  WillsProvider({Key key, @required this.store, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(WillsProvider old) => store != old.store;

}

abstract class ReactiveWidget extends StatefulWidget {

  ReactiveWidget({key}): super(key: key);

  ReactiveState<Store, ReactiveWidget> createState();

}

//typedef dynamic OnCall(List);
//refer https://stackoverflow.com/questions/13731631/creating-function-with-variable-number-of-arguments-or-parameters-in-dart
//class VarargsFunction {
//
//  Function _onCall;
//
//  //ReactiveState<Store<Reactive>, ReactiveWidget> _context;
//  Watcher _watcher;
//
//  VarargsFunction(this._watcher, this._onCall);
//
//  call() => _onCall();
//
//  noSuchMethod(Invocation invocation) {
//    final positionalArguments = invocation.positionalArguments;
//    final namedArguments = invocation.namedArguments;
//    Watcher.pushActive(_watcher);
//    var result = Function.apply(_onCall, positionalArguments, namedArguments);
//    Watcher.popActive();
//    return result;
//  }
//}

typedef void UnwatchFunc();

willsWatch(func, handler, [bool immediate = true]) {
  Watcher watcher = new UserWatcher(handler);
  Watcher.pushActive(watcher);
  func();
  Watcher.popActive();
  if(immediate) handler();
  return () {
    watcher.clear();
  };
}

abstract class ReactiveState<S extends Store<Reactive>, W extends ReactiveWidget> extends State<W> {

  RenderWatcher _watcher = new RenderWatcher();

  S get $store => (context?.inheritFromWidgetOfExactType(WillsProvider) as WillsProvider)?.store;

  @override
  void initState() {
    super.initState();
    _watcher._bind(this);
  }

  Widget build(BuildContext context) {
    _watcher.clear();
    Watcher.pushActive(_watcher);
    Widget w = render(context);
    Watcher.popActive();
    return w;
  }

  Widget render(BuildContext context);

  $enterScope() {
    Watcher.pushActive(_watcher);
  }

  $leaveScope() {
    Watcher.popActive();
  }

  UnwatchFunc $watch(funcOrExpression, fn) {
    ObserverFunc func;
    if(funcOrExpression is String) {
      func = () {
        List<String> props = funcOrExpression.split(r'\.');
        dynamic host = this;
        for(String prop in props) {
          host = host[prop];
        }
      };
    } else {
      func = funcOrExpression;
    }
    Watcher watcher = new UserWatcher(fn);
    Watcher.pushActive(watcher);
    func();
    Watcher.popActive();
    return () {
      watcher.clear();
    };
  }

  @override
  void dispose() {
    super.dispose();
    _watcher._unbind(this);
  }

}

