import 'dart:convert';

import 'package:graph/data/song_at_date.dart';

import '../data/sum_of_songs_by_date.dart';

class SongsConfigAdapter {
  final String jsonString;

  const SongsConfigAdapter(this.jsonString);

  List<SongAtDate> _parseSongAtDateList() {
    return SongAtDate.fromJsonArray(json.decode(jsonString));
  }

  List<String> _getMergedSongsList(DateTime? from, DateTime? until) {
    var list = _parseSongAtDateList();
    List<String> merged = [];
    for (var element in list) {
      // from <= xxx <= until
      if (from == null ||
          element.datetime.isAfter(from) ||
          element.datetime == from) {
        if (until == null ||
            element.datetime.isBefore(until) ||
            element.datetime == until) {
          merged.addAll(element.songs);
        }
      }
    }
    return merged;
  }

  Map<String, int> getSongsCountWithinPeriod(
      {DateTime? from, DateTime? until}) {
    var list = _getMergedSongsList(from, until);
    Map<String, int> dict = {};

    for (var x in list) {
      dict[x] = (!dict.containsKey(x) ? (1) : (dict[x]! + 1));
    }
    return dict;
  }

  List<SumOfSongsByDate> getSumOfSongsByDate(
      {DateTime? from, DateTime? until}) {
    var list = _parseSongAtDateList();
    var dl = list.map((e) => e.datetime).toList();
    var dateList = dl.slicePerDay();
    dateList.sort();
    if (dateList.isEmpty) {
      return List.empty();
    }

    List<SumOfSongsByDate> ret = [];
    var fromDt = from ?? dateList[0];

    for (var date in dateList) {
      if (date.isBefore(fromDt)) {
        // out of range.
        continue;
      }

      if (until != null && date.isAfter(until)) {
        // out of range.
        continue;
      }
      var ut2 = date.add(const Duration(hours: 23, minutes: 59, seconds: 59));
      if (until != null) {
        if (ut2.isAfter(until)) {
          ut2 = until;
        }
      }

      var nst = SumOfSongsByDate(
          date, getSongsCountWithinPeriod(from: fromDt, until: ut2));
      ret.add(nst);
    }
    return ret;
  }
}

extension Slice on List<DateTime> {
  //TODO: Dirty code...
  List<DateTime> slicePerDay() {
    var dateList = this;
    dateList.sort();
    if (dateList.isEmpty) {
      return List.empty();
    }

    DateTime fromD =
        DateTime(dateList[0].year, dateList[0].month, dateList[0].day);
    DateTime untilD = fromD.add(const Duration(days: 1));
    bool isMerged = false;
    List<DateTime> mergedDt = [];

    for (var d in dateList) {
      if (d == fromD || d.isAfter(fromD)) {
        if (d.isBefore(untilD)) {
          if (isMerged) {
            continue;
          }
          isMerged = true;
          mergedDt.add(fromD);
          continue;
        }
      }
      // out of range
      fromD = DateTime(d.year, d.month, d.day);
      untilD = fromD.add(const Duration(days: 1));
      isMerged = false;

      if (d == fromD || d.isAfter(fromD)) {
        if (d.isBefore(untilD)) {
          isMerged = true;
          mergedDt.add(fromD);
          continue;
        }
      }
    }
    return mergedDt;
  }
}
