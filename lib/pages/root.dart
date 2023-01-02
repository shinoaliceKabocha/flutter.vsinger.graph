import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graph/controller/songs_config_adapter.dart';
import 'package:graph/util/date_time_ext.dart';
import 'package:graph/util/color_map.dart';
import 'package:graph/widget/from_until_dates_picker.dart';

import '../data/sum_of_songs_by_date.dart';

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    String app = const String.fromEnvironment('APP');
    String titleName = const String.fromEnvironment('TITLE');
    app = (app.isEmpty) ? "dummyAppName" : app;
    titleName = (titleName.isEmpty) ? "dummyTitleName" : titleName;

    return MaterialApp(
      title: app,
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'NotoSansJP',
      ),
      home: RootPage(title: titleName),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key, required this.title});

  final String title;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> implements IFromUntilDatesPicker {
  SongsConfigAdapter? songConfigAdapter;
  Map<String, int> songCountDict = {};
  List<SumOfSongsByDate> sumOfSongsByDate = [];

  DateTime? fromDt;
  DateTime? untilDt;

  @override
  void initState() {
    super.initState();
    _initStateAsync();
  }

  void _initStateAsync() async {
    String json = await rootBundle.loadString('assets/songs.json');
    songConfigAdapter = SongsConfigAdapter(json);
    _updateData();
  }

  void _updateData() {
    setState(() {
      songCountDict = songConfigAdapter?.getSongsCountWithinPeriod(
              from: fromDt, until: untilDt) ??
          {};
      sumOfSongsByDate = songConfigAdapter?.getSumOfSongsByDate(
              from: fromDt, until: untilDt) ??
          [];
    });
  }

  @override
  void setDateEvent(DateTime fromDt, DateTime untilDt) {
    this.fromDt = fromDt;
    this.untilDt = untilDt;
    _updateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.only(right: 100, left: 100, bottom: 50),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                FromUntilDatesPicker(this),
                SizedBox(
                  height: 500,
                  child: BarChart(_barChartData()),
                ),
                const SizedBox(
                  height: 50,
                ),
                SizedBox(height: 500, child: LineChart(_lineChartData())),
                const SizedBox(
                  height: 30,
                ),
                _getLineChartBarLabelGrid(),
              ],
            )));
  }

  // Line chart label.
  Widget _getLineChartBarLabelGrid() {
    Map<String, List<DateTimeAndSum>> lineChartRawData =
        sumOfSongsByDate.convert();
    List<String> songs = lineChartRawData.keys.toList();
    double height = 50 + (songs.length ~/ 5 * 50);
    return SizedBox(
        height: height,
        child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, childAspectRatio: 6.0),
            shrinkWrap: true,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              return Text("■ ${songs.asMap()[index]}\t",
                  style: TextStyle(color: ColorMap.getByIndex(index)));
            }));
  }

  // Line chart
  LineChartData _lineChartData() {
    var times = sumOfSongsByDate.map((e) => e.time).toList();
    times.sort();
    if (times.isEmpty) {
      return LineChartData();
    }
    DateTime baseDt = times[0];

    return LineChartData(
      minX: 0,
      minY: 0,
      baselineX: 0,
      baselineY: 0,
      lineBarsData: _getLineChartBarData(),
      titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 1.0)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            interval: 1.0,
            getTitlesWidget: (index, _) => SideTitleWidget(
              space: 1,
              axisSide: AxisSide.bottom,
              child: Text(
                  baseDt.add(Duration(days: index.toInt())).toShortString()),
            ),
          ))),
      gridData: FlGridData(
        drawVerticalLine: false,
        drawHorizontalLine: true,
      ),
      lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (value) => value
                  .map((e) => LineTooltipItem(
                      "${_getSongNameByIndexForLineChart(e.barIndex)}: ${e.y}",
                      TextStyle(
                          color: ColorMap.getByIndex(e.barIndex),
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left))
                  .toList())),
    );
  }

  List<LineChartBarData> _getLineChartBarData() {
    Map<String, List<DateTimeAndSum>> lineChartRawData =
        sumOfSongsByDate.convert();
    List<String> songs = lineChartRawData.keys.toList();
    List<LineChartBarData> ret = [];

    songs.asMap().forEach((index, song) {
      List<FlSpot> spotList = [];
      lineChartRawData[song]?.forEach((element) {
        spotList.add(FlSpot(element.x.toDouble(), element.y.toDouble()));
      });
      ret.add(LineChartBarData(
        spots: spotList,
        color: ColorMap.getByIndex(index),
        barWidth: 4,
        dotData: FlDotData(show: true),
      ));
    });
    return ret;
  }

  String _getSongNameByIndexForLineChart(int index) {
    Map<String, List<DateTimeAndSum>> lineChartRawData =
        sumOfSongsByDate.convert();
    List<String> songs = lineChartRawData.keys.toList();
    if (index < 0 || songs.length <= index) {
      throw Exception("not found");
    }
    return songs[index];
  }

  // Bar chart
  BarChartData _barChartData() {
    return BarChartData(
        borderData: FlBorderData(
            border: const Border(
          top: BorderSide.none,
          right: BorderSide.none,
          left: BorderSide(width: 1),
          bottom: BorderSide(width: 1),
        )),
        gridData: FlGridData(drawHorizontalLine: true, drawVerticalLine: false),
        groupsSpace: 10,
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, interval: 1.0)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            interval: 1.0,
            showTitles: true,
            getTitlesWidget: (index, _) => SideTitleWidget(
              space: 1,
              axisSide: AxisSide.bottom,
              child: Text(
                _getSongNameByIndexForBarChart(index.toInt()),
              ),
            ),
          )),
        ),
        barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                    BarTooltipItem(
                        "${_getSongNameByIndexForBarChart(groupIndex)}: ${rod.toY}",
                        const TextStyle(color: Colors.white)))),
        barGroups: _getSongGroupDataList());
  }

  List<BarChartGroupData> _getSongGroupDataList() {
    List<BarChartGroupData> ret = [];
    songCountDict.keys.toList().asMap().forEach((index, value) {
      ret.add(BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            toY: songCountDict[value]!.toDouble(),
            width: 15,
            color: ColorMap.getByIndex(index))
      ]));
    });
    return ret;
  }

  String _getSongNameByIndexForBarChart(int index) {
    if (index < 0 || songCountDict.keys.length <= index) {
      throw Exception("not found");
    }
    return songCountDict.keys.toList()[index];
  }
}
