import 'package:flutter/material.dart';

class CPoint {
  Offset start;
  Offset end;
  List<Offset>? pathPoints = [];
  bool isSelected = false;
  String content = "";
  String? injectionType = "";
  int order;
  CPoint(
      {required this.start,
      required this.end,
      this.injectionType,
      required this.content,
      required this.order});
}
