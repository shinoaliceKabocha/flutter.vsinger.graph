class SumOfSongsByDate {
  final DateTime time;
  final Map<String, int> songCountDict;

  const SumOfSongsByDate(this.time, this.songCountDict);
}

class DateTimeAndSum {
  final DateTime time;
  final int x;
  final int y;

  const DateTimeAndSum(this.time, this.x, this.y);
}

extension Cast on List<SumOfSongsByDate> {
  Map<String, List<DateTimeAndSum>> convert() {
    var times = map((e) => e.time).toList();
    times.sort();
    if (times.isEmpty) {
      return {};
    }
    DateTime baseDt = times[0];

    List<String> tmpSongs = [];
    forEach((e) {
      tmpSongs.addAll(e.songCountDict.keys);
    });
    var songs = tmpSongs.toSet().toList();

    Map<String, List<DateTimeAndSum>> ret = {};
    for (var song in songs) {
      List<DateTimeAndSum> tmp = [];
      forEach((e) => {
            tmp.add(DateTimeAndSum(e.time, e.time.difference(baseDt).inDays,
                e.songCountDict[song] ?? 0))
          });
      ret[song] = tmp;
    }
    return ret;
  }
}
