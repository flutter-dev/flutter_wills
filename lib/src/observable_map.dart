import 'dart:collection';

import 'package:flutter_wills/src/core.dart';

//refer: https://github.com/dart-lang/observable/blob/master/lib/src/observable_map.dart
class ObservableMap<K, V> extends MapBase<K, V> with Reactive {

  final Map<K, V> _map;

  ObservableMap() : _map = new HashMap<K, V>();

  ObservableMap.linked() : _map = new LinkedHashMap<K, V>();

  ObservableMap.sorted() : _map = new SplayTreeMap<K, V>();

  factory ObservableMap.from(Map<K, V> other) {
    return new ObservableMap<K, V>.createFromType(other)..addAll(other);
  }

  factory ObservableMap.createFromType(Map<K, V> other) {
    ObservableMap<K, V> result;
    if (other is SplayTreeMap) {
      result = new ObservableMap<K, V>.sorted();
    } else if (other is LinkedHashMap) {
      result = new ObservableMap<K, V>.linked();
    } else {
      result = new ObservableMap<K, V>();
    }
    return result;
  }

  @override
  Iterable<K> get keys {
    $observe();
    return _map.keys;
  }

  @override
  V operator [](Object key) {
    $observe();
    return _map[key];
  }


  @override
  void operator []=(K key, V value) {
    _map[key] = value;
    $notify();
  }

  @override
  void clear() {
    _map.clear();
    $notify();
  }

  @override
  V remove(Object key) {
    V result = _map.remove(key);
    $notify();
    return result;
  }
}