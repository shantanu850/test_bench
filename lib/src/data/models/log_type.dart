import 'package:test_bench/src/res/colors.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

enum LogType {
  http('HTTP'),
  debug('Debug'),
  info('Info'),
  error('Error');

  const LogType(this.name);

  Color getColor() {
    switch (this) {
      case LogType.http:
        return TestBenchColors.blueAccent;
      case LogType.debug:
        return TestBenchColors.greenAccent;
      case LogType.info:
        return TestBenchColors.blueAccent;
      case LogType.error:
        return TestBenchColors.red;
    }
  }

  static LogType? getTypeFromLevel(Level level) {
    switch (level) {
      case Level.trace:
      case Level.debug:
        return LogType.debug;
      case Level.info:
      case Level.warning:
        return LogType.info;
      case Level.error:
      case Level.fatal:
        return LogType.error;
      default:
        return null;
    }
  }

  final String name;
}
