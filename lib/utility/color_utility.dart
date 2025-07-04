import 'package:flutter/material.dart';

/// 文字列からColorを取得する
Color getColorFromString(String color) {
  switch (color) {
    case 'blue':
      return Colors.blue;
    case 'red':
      return Colors.red;
    case 'green':
      return Colors.green;
    case 'gold':
      return Colors.amber;
    case 'purple':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}
