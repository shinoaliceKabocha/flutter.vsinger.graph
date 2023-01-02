class SongAtDate {
  const SongAtDate(this.datetime, this.songs);

  final DateTime datetime;
  final List<String> songs;

  factory SongAtDate.fromJson(Map<dynamic, dynamic> json) {
    return SongAtDate(
        DateTime.parse(json['datetime'].toString()),
        (json['songs'] as List<dynamic>)
            .map((e) => e.toString().trim())
            .toList());
  }

  static List<SongAtDate> fromJsonArray(List<dynamic> jsonArray) {
    return jsonArray.map((j) => SongAtDate.fromJson(j)).toList();
  }
}
