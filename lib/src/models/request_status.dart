import 'package:test_bench/src/res/colors.dart';
import 'package:flutter/material.dart';

enum RequestStatus {
  sending(TestBenchColors.yellow),
  success(TestBenchColors.green),
  error(TestBenchColors.red),
  noInternet(TestBenchColors.red);

  const RequestStatus(this.color);

  final Color color;
}
