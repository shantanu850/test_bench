import 'package:test_bench/src/res/colors.dart';
import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  const ProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: TestBenchColors.backgroundGrey.withOpacity(0.8),
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
