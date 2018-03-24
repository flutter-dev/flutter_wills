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

  int id = 0;

  LinkedHashSet<Observer> deps = new LinkedHashSet();

  static int _uid = 0;

  static const int MAX_UPDATE_COUNT = 99;

  static List<Watcher> _trackWatchers = new List();

  static LinkedHashSet<Watcher> _pendingUpdateWatchers = new LinkedHashSet();

  static HashMap<int, int> _circular = new HashMap();

  static bool _hasScheduledUpdateTask = false;

  static _addPendingWatcher(Watcher w) {
    _pendingUpdateWatchers.add(w);
    if(!_hasScheduledUpdateTask) {
      _scheduleUpdateTask();
      _hasScheduledUpdateTask = true;
    }
  }

  static _scheduleUpdateTask() {
    scheduleMicrotask(() {
      List<Watcher> watchers = _pendingUpdateWatchers.toList();
      _pendingUpdateWatchers.clear();

      watchers.forEach((w){
        assert(() {
          if(_circular[w.id] != null) {
            if(++_circular[w.id] > MAX_UPDATE_COUNT) {
              throw new StateError('it seem to run in a infinite loop, please check, watcher: ${w.id}');
            }
          } else {
            _circular[w.id] = 0;
          }
          return true;
        }());

        w.run();
      });

      if(_pendingUpdateWatchers.isNotEmpty) { // check again
        _scheduleUpdateTask();
      } else {
        _resetScheduleState();
      }
    });
  }

  static _resetScheduleState() {
    _hasScheduledUpdateTask = false;
    assert(() {
      _circular.clear();
      return true;
    }());
  }

  static Watcher active;

  static pushActive(Watcher w) {
    _trackWatchers.add(active);
    active = w;
  }

  static popActive() {
    active = _trackWatchers.removeLast();
  }

  Watcher(): id = _uid++;

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