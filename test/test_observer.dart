import 'package:flutter_wills/flutter_wills.dart';
import 'package:test/test.dart';

main() {
  test('test observable list add', () {
    ObservableList<int> arrs = new ObservableList.from([1, 2, 3]);
    willsWatch(()=> arrs[0], () {
      fail('fail pass observable list add');
    }, false);
    arrs.add(0);
  });

  test('test observable list remove 1', () {
    ObservableList<int> arrs = new ObservableList.from([1, 2, 3]);
    willsWatch(()=> arrs[2], () {
      expect(1, 1);
    }, false);
    arrs.removeAt(2);
  });

  test('test observable list remove 2', () {
    ObservableList<int> arrs = new ObservableList.from([1, 2, 3]);
    willsWatch(()=> arrs[2], () {
      expect(1, 1);
    }, false);
    arrs.remove(3);
  });

  test('test observable list update', () {
    ObservableList<int> arrs = new ObservableList.from([1, 2, 3]);
    willsWatch(()=> arrs[2], () {
      expect(1, 1);
    }, false);
    arrs[2] = 4;
  });

  test('test observable map add 1', () {
    ObservableMap<String, int> map = new ObservableMap.from({'0': 0, '1': 1, '2': 2});
    willsWatch(()=> map['2'], () {
      fail('fail pass observable map add');
    }, false);
    map['3'] = 3;
  });

  test('test observable map add 2', () {
    ObservableMap<String, int> map = new ObservableMap.from({'0': 0, '1': 1, '2': 2});
    willsWatch((){
      for(var key in map.keys);
    }, () {
      print('pass observable map add 2');
      expect(1, 1);
    }, false);
    map['3'] = 3;
  });

  test('test observable map add 3', () {
    ObservableMap<String, int> map = new ObservableMap.from({'0': 0, '1': 1, '2': 2});
    willsWatch(() {
     for(var value in map.values);
    }, () {
      print('pass observable map add 3');
      expect(1, 1);
    }, false);
    map['3'] = 3;
  });

  test('test observable map remove 1', () {
    ObservableMap<String, int> map = new ObservableMap.from({'0': 0, '1': 1, '2': 2});
    willsWatch(() {
      for(var value in map.values);
    }, () {
      print('pass observable map remove 1');
      expect(1, 1);
    }, false);
    map.remove('2');
  });

  test('test observable map remove 2', () {
    ObservableMap<String, int> map = new ObservableMap.from({'0': 0, '1': 1, '2': 2});
    willsWatch(()=> map['2'], () {
      print('pass observable map remove 2');
      expect(1, 1);
    }, false);
    map.remove('2');
  });

  test('test observable map update', () {
    ObservableMap<String, int> map = new ObservableMap.from({'0': 0, '1': 1, '2': 2});
    willsWatch(()=> map['2'], () {
      print('pass observable map update');
      expect(1, 1);
    }, false);
    map['2'] = 3;
  });
}