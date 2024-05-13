import 'package:test_bench/src/test_bench_helper.dart';
import 'package:flutter/material.dart';
import 'package:inspector/inspector.dart';

class CrInspector extends StatelessWidget {
  const CrInspector({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TestBenchHelper.instance.inspectorNotifier,
      // ignore: Prefer-trailing-comma
      builder: (_, enabled, __) => Inspector(
        isEnabled: enabled,
        child: child,
      ),
    );
  }
}
