import 'package:flutter_test/flutter_test.dart';
import 'package:graph/controller/songs_config_adapter.dart';

void main() {
  var json = '''
    [
      {
        "datetime": "2023-01-01",
        "songs": [
          "a",
          "hoge",
          "test test test"
        ]
      },
      {
        "datetime": "2023-01-02 23:59:20",
        "songs": [
          "b",
          "hoge",
          "test test test"
        ]
      },
      {
        "datetime": "2023-01-03 10:11:13",
        "songs": [
          "c",
          "test test test"
        ]
      },
      {
        "datetime": "2022-12-31 08:08:10",
        "songs": [
          "d",
          "hoge",
          "test test test"
        ]
      },
      {
        "datetime": "2023-01-01 08:08:10",
        "songs": [
          "a2",
          "test test test"
        ]
      }
    ]
  ''';
  var adapter = SongsConfigAdapter(json);

  test('test SongsConfigAdapter # getSongsCountWithinPeriod', () {
    // all
    var r1 = adapter.getSongsCountWithinPeriod();
    expect(r1['a'], 1);
    expect(r1['a2'], 1);
    expect(r1['hoge'], 3);
    expect(r1['test test test'], 5);
    expect(r1['b'], 1);
    expect(r1['c'], 1);
    expect(r1['d'], 1);

    var r2 = adapter.getSongsCountWithinPeriod(
        from: DateTime.parse('2023-01-01'), until: null);
    expect(r2['a'], 1);
    expect(r2['a2'], 1);
    expect(r2['hoge'], 2);
    expect(r2['test test test'], 4);
    expect(r2['b'], 1);
    expect(r2['c'], 1);
    expect(r2['d'], null);

    var r3 = adapter.getSongsCountWithinPeriod(
        from: DateTime.parse('2023-01-01'),
        until: DateTime.parse('2023-01-02 23:59:59'));
    expect(r3['a'], 1);
    expect(r3['a2'], 1);
    expect(r3['hoge'], 2);
    expect(r3['test test test'], 3);
    expect(r3['b'], 1);
    expect(r3['c'], null);
    expect(r3['d'], null);

    // invalid case
    var r4 = adapter.getSongsCountWithinPeriod(
        from: DateTime.parse('2023-01-02 23:59:59'),
        until: DateTime.parse('2023-01-01'));
    expect(r4.keys.length, 0);
    expect(r4.values.length, 0);
  });

  test('test SongsConfigAdapter # getSumOfSongsByDate', () {
    DateTime dt20221231 = DateTime(2022, 12, 31);
    DateTime dt20230101 = DateTime(2023, 1, 1);
    DateTime dt20230102 = DateTime(2023, 1, 2);
    DateTime dt20230103 = DateTime(2023, 1, 3);

    // all
    var r = adapter.getSumOfSongsByDate();
    expect(r.length, 4);
    for (var element in r) {
      if (element.time == dt20221231) {
        expect(element.songCountDict.keys.length, 3);
        expect(element.songCountDict['d'], 1);
        expect(element.songCountDict['hoge'], 1);
        expect(element.songCountDict['test test test'], 1);
      } else if (element.time == dt20230101) {
        expect(element.songCountDict.keys.length, 5);
        expect(element.songCountDict['a'], 1);
        expect(element.songCountDict['a2'], 1);
        expect(element.songCountDict['d'], 1);
        expect(element.songCountDict['hoge'], 2);
        expect(element.songCountDict['test test test'], 3);
      } else if (element.time == dt20230102) {
        expect(element.songCountDict.keys.length, 6);
        expect(element.songCountDict['a'], 1);
        expect(element.songCountDict['a2'], 1);
        expect(element.songCountDict['d'], 1);
        expect(element.songCountDict['b'], 1);
        expect(element.songCountDict['hoge'], 3);
        expect(element.songCountDict['test test test'], 4);
      } else if (element.time == dt20230103) {
        expect(element.songCountDict.keys.length, 7);
        expect(element.songCountDict['a'], 1);
        expect(element.songCountDict['c'], 1);
        expect(element.songCountDict['a2'], 1);
        expect(element.songCountDict['d'], 1);
        expect(element.songCountDict['b'], 1);
        expect(element.songCountDict['hoge'], 3);
        expect(element.songCountDict['test test test'], 5);
      } else {
        throw Exception("unexpected time");
      }
    }

    // from:2023/01/01, until:unlimited
    r = adapter.getSumOfSongsByDate(from: dt20230101);
    expect(r.length, 3);
    for (var element in r) {
      if (element.time == dt20230101) {
        expect(element.songCountDict.keys.length, 4);
        expect(element.songCountDict['a'], 1);
        expect(element.songCountDict['a2'], 1);
        expect(element.songCountDict['hoge'], 1);
        expect(element.songCountDict['test test test'], 2);
      } else if (element.time == dt20230102) {
        expect(element.songCountDict.keys.length, 5);
        expect(element.songCountDict['a'], 1);
        expect(element.songCountDict['a2'], 1);
        expect(element.songCountDict['b'], 1);
        expect(element.songCountDict['hoge'], 2);
        expect(element.songCountDict['test test test'], 3);
      } else if (element.time == dt20230103) {
        expect(element.songCountDict.keys.length, 6);
        expect(element.songCountDict['a'], 1);
        expect(element.songCountDict['c'], 1);
        expect(element.songCountDict['a2'], 1);
        expect(element.songCountDict['b'], 1);
        expect(element.songCountDict['hoge'], 2);
        expect(element.songCountDict['test test test'], 4);
      } else {
        throw Exception("unexpected time");
      }
    }

    // from: 2023/01/01 00:00:00, until: 2023/01/01 08:00:00
    r = adapter.getSumOfSongsByDate(
        from: dt20230101, until: DateTime(2023, 01, 01, 08, 00, 00));
    expect(r.length, 1);
    for (var element in r) {
      if (element.time == dt20230101) {
        expect(element.songCountDict.keys.length, 3);
        expect(element.songCountDict['a'], 1);
        expect(element.songCountDict['hoge'], 1);
        expect(element.songCountDict['test test test'], 1);
      } else {
        throw Exception("unexpected time");
      }
    }
  });
}
