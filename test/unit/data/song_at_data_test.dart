import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graph/data/song_at_date.dart';

void main() {
  // for loading assets data.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parse test assets/songs.json', () {
    var future = rootBundle.loadString('assets/songs.json');
    future.then((value) =>
        SongAtDate.fromJsonArray(json.decode(value)).forEach((element) {
          debugPrint("${element.songs.length} songs at ${element.datetime}");
        }));
  });
}
