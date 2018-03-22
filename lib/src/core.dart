import 'dart:async';
import 'dart:collection';

abstract class Reactive {
  Map<dynamic, Observer> _mapping = new HashMap();

  void $observe([field = '_']) {
    if(!_mapping.containsKey(field)) {
      _mapping[field] = new Observer();
    }
    _mapping[field].$depend();
  }

  void $notify([field = '_']) {
    _mapping[field]?.$notify();
  }

  void $checkType(val) {
    if(val is Reactive) val.$observe();
  }

  void $destroy() {
    _mapping.values.forEach((Observer o) {
      o.destroy();
    });
    _mapping.clear();
  }
}


class Observer {

  LinkedHashSet<Watcher> watchers = new LinkedHashSet();

  void $depend() {
    if(Watcher.active != null) {
      Watcher.active._addDep(this);
      watchers.add(Watcher.active);
    }
  }

  void $notify() {
    watchers.forEach((w) {
      //w.run();
      Watcher._addPendingWatcher(w);
    });
  }

  void _remove(Watcher w) {
    watchers.remove(w);
    w._removeDep(this);
  }

  void destroy() {
    List<Watcher> list = watchers.toList();
    for(int len = list.length - 1; len >= 0; len--) {
      _remove(list[len]);
    }
  }

}

class Watcher {

  LinkedHashSet<Observer> deps = new LinkedHashSet();

  static List<Watcher> _trackWatchers = new List();

  static LinkedHashSet<Watcher> _pendingUpdateWatchers = new LinkedHashSet();

  static bool _hasScheduledUpdateTask = false;

  static _addPendingWatcher(Watcher w) {
    _pendingUpdateWatchers.add(w);
    _scheduleUpdateTask();
  }

  static _scheduleUpdateTask() {
    if(!_hasScheduledUpdateTask) {
      scheduleMicrotask(() {
        _pendingUpdateWatchers.forEach((w) => w.run());
        _pendingUpdateWatchers.clear();
        _hasScheduledUpdateTask = false;
      });
    }
    _hasScheduledUpdateTask = true;
  }

  static Watcher active;

  static pushActive(Watcher w) {
    _trackWatchers.add(active);
    active = w;
  }

  static popActive() {
    active = _trackWatchers.removeLast();
  }


  void run() {}

  void _addDep(Observer o) {
    deps.add(o);
  }

  void _removeDep(Observer o) {
    deps.remove(o);
  }

  void clear() {
    List list = deps.toList();
    for(int len = list.length - 1; len >= 0; len--) {
      list[len]?._remove(this);
    }
  }

}