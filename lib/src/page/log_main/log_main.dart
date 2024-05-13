import 'package:test_bench/test_bench.dart';
import 'package:test_bench/src/test_bench_helper.dart';
import 'package:test_bench/src/managers/log_manager.dart';
import 'package:test_bench/src/page/log_main/log_main_mobile.dart';
import 'package:test_bench/src/page/log_main/log_main_web.dart';
import 'package:test_bench/src/widget/adaptive_layout/adaptive_layout_widget.dart';
import 'package:flutter/material.dart';

class MainLogPage extends StatefulWidget {
  const MainLogPage({
    required this.navigationKey,
    required this.onLoggerClose,
    super.key,
  });

  final GlobalKey<NavigatorState> navigationKey;
  final VoidCallback onLoggerClose;

  static void cleanLogs() {
    cleanDebug();
    cleanError();
    cleanInfo();
    cleanHttpLogs();
  }

  static void cleanHttpLogs() {
    HttpLogManager.instance.cleanAllLogs();
  }

  static void cleanDebug() {
    LogManager.instance.cleanDebug();
  }

  static void cleanInfo() {
    LogManager.instance.cleanInfo();
  }

  static void cleanError() {
    LogManager.instance.cleanError();
  }

  @override
  _MainLogPageState createState() => _MainLogPageState();
}

class _MainLogPageState extends State<MainLogPage> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: TestBenchHelper.instance.theme,
      child: ValueListenableBuilder<bool>(
        valueListenable: TestBenchHelper.instance.loggerShowingNotifier,
        // ignore: prefer-trailing-comma
        builder: (_, showLogger, __) => Offstage(
          offstage: !showLogger,
          child: Navigator(
            key: widget.navigationKey,
            onGenerateRoute: _onGenerateRoute,
          ),
        ),
      ),
    );
  }

  Route? _onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      builder: (context) => AdaptiveLayoutWidget(
        mobileLayoutWidget: MainLogMobilePage(
          onLoggerClose: widget.onLoggerClose,
        ),
        webLayoutWidget: MainLogWebPage(
          onLoggerClose: widget.onLoggerClose,
        ),
      ),
      settings: settings,
    );
  }
}
