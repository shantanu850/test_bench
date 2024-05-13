import 'package:test_bench/test_bench.dart';
import 'package:test_bench/src/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final class LogBean implements Comparable<LogBean> {
  LogBean({
    required this.message,
    required this.time,
    required this.stackTrace,
    this.showToast = false,
    this.type,
    this.data = const {},
    this.key,
    String? id,
  })  : id = id ?? const Uuid().v4(),
        color = type?.getColor() ?? TestBenchColors.primaryColor;

  final int? key;
  final String id;
  final dynamic message;
  final DateTime time;
  final String? stackTrace;
  final Map<String, dynamic>? data;
  LogType? type;
  Color color;
  bool showToast;

  @override
  int compareTo(LogBean other) {
    return other.time.isAfter(time) ? 1 : -1;
  }
}
