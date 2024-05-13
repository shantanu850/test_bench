import 'package:test_bench/test_bench.dart';
import 'package:test_bench/src/res/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

final class TestBenchHelper {
  TestBenchHelper._();

  static const _proxySharedPrefKey = 'cr_logger_charles_proxy';
  static TestBenchHelper instance = TestBenchHelper._();

  final lock = Lock();
  final inspectorNotifier = ValueNotifier<bool>(false);
  final loggerShowingNotifier = ValueNotifier<bool>(false);

  final maxLogsCount = TestBenchInitializer.instance.maxCurrentLogsCount;

  final maxDBLogsCount = TestBenchInitializer.instance.maxDBLogsCount;
  late final PackageInfo packageInfo;
  late final SharedPreferences _prefs;

  ThemeData theme = loggerTheme;

  bool get isLoggerShowing => loggerShowingNotifier.value;

  bool get useDB {
    final useTestBenchInReleaseBuild =
        TestBenchInitializer.instance.useTestBenchInReleaseBuild;
    final useDB = TestBenchInitializer.instance.useDB;

    return useDB && (useTestBenchInReleaseBuild || !kReleaseMode) && !kIsWeb;
  }

  /// Condition that determines whether or not to print logs
  bool get printLogs {
    final printLogs = TestBenchInitializer.instance.printLogs;
    final useTestBenchInReleaseBuild =
        TestBenchInitializer.instance.useTestBenchInReleaseBuild;

    return printLogs && (useTestBenchInReleaseBuild || !kReleaseMode);
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
  }

  Future<bool> setProxyToSharedPref(String? proxy) async {
    return proxy != null
        ? _prefs.setString(_proxySharedPrefKey, proxy)
        : _prefs.remove(_proxySharedPrefKey);
  }

  String? getProxyFromSharedPref() => _prefs.getString(_proxySharedPrefKey);

  void showLogger() => loggerShowingNotifier.value = true;

  void hideLogger() => loggerShowingNotifier.value = false;
}
