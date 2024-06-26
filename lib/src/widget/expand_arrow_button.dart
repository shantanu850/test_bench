import 'dart:math' as math;
import 'package:test_bench/generated/assets.dart';
import 'package:test_bench/src/extensions/extensions.dart';
import 'package:flutter/material.dart';

class ExpandArrowButton extends StatelessWidget {
  const ExpandArrowButton({
    required this.isExpanded,
    this.onTap,
    super.key,
  });

  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 28,
      child: Transform.rotate(
        angle: isExpanded ? math.pi : 0,
        child: IconButton(
          onPressed: onTap,
          icon: ImageExt.fromPackage(
            TestBenchAssets.assetsArrowDown,
            height: 28,
            width: 28,
          ),
          iconSize: 28,
          splashRadius: 20,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
