import 'package:flutter/material.dart';

class ColorMap {
  static const List<Color> _colors = [
    Colors.amber,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.green,
    Colors.tealAccent,
    Colors.deepOrangeAccent,
    Colors.brown,
    Colors.indigo,
    Colors.pink,
    Colors.teal,
    Colors.black,
    Colors.deepPurpleAccent,
    Colors.lightBlueAccent,
    Colors.blueGrey,
  ];

  static Color getByIndex(int index) {
    int id = (_colors.length <= index) ? (index - (_colors.length)) : index;
    if (id < 0) {
      throw Exception("out of range");
    }
    return _colors[id];
  }
}
