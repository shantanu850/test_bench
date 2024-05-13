import 'package:flutter/material.dart';

extension ImageExt on Image {
  static Image fromPackage(
    String name, {
    double width = 24,
    double height = 24,
  }) =>
      Image.asset(
        name,
        package: 'test_bench',
        width: width,
        height: height,
      );
}
