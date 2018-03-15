import 'dart:collection';

import 'package:flutter_wills/src/core.dart';

//refer: https://github.com/dart-lang/observable/blob/master/lib/src/observable_list.dart
class ObservableList<E> extends ListBase<E> with Reactive {

  //Observer $ob = new Observer();

  final List<E> _list;

  ObservableList([int length])
      : _list = length != null ? new List<E>(length) : <E>[];

  ObservableList.from(Iterable other) : _list = new List<E>.from(other);

  @override
  E operator [](int index) {
    $observe();
    return _list[index];
  }

  @override
  void operator []=(int index, E value) {
    if(_list[index] == value) return;
    _list[index] = value;
    $notify();
  }

  @override
  int get length {
    $observe();
    return _list.length;
  }

  @override
  set length(int value) {
    int len = _list.length;
    if (len == value) return;
    _list.length = value;
    $notify();
  }

}