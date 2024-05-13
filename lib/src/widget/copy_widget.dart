import 'package:test_bench/generated/assets.dart';
import 'package:test_bench/src/extensions/extensions.dart';
import 'package:flutter/material.dart';

class CopyWidget extends StatelessWidget {
  const CopyWidget({
    required this.onCopy,
    super.key,
  });

  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 28,
      child: IconButton(
        onPressed: onCopy,
        icon: ImageExt.fromPackage(
          TestBenchAssets.assetsContentCopy,
          height: 20,
          width: 20,
        ),
        iconSize: 20,
        splashRadius: 20,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
