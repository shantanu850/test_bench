import 'package:test_bench/test_bench.dart';
import 'package:test_bench/generated/assets.dart';
import 'package:test_bench/src/controllers/logs_mode.dart';
import 'package:test_bench/src/controllers/logs_mode_controller.dart';
import 'package:test_bench/src/test_bench_helper.dart';
import 'package:test_bench/src/extensions/do_post_frame.dart';
import 'package:test_bench/src/extensions/extensions.dart';
import 'package:test_bench/src/managers/log_manager.dart';
import 'package:test_bench/src/page/http_logs/http_logs_page.dart';
import 'package:test_bench/src/page/log_main/widgets/mobile_header_widget.dart';
import 'package:test_bench/src/page/logs/log_local_detail_page.dart';
import 'package:test_bench/src/page/logs/log_page.dart';
import 'package:test_bench/src/page/widgets/popup_menu.dart';
import 'package:test_bench/src/res/colors.dart';
import 'package:test_bench/src/res/styles.dart';
import 'package:test_bench/src/widget/cr_app_bar.dart';
import 'package:test_bench/src/widget/options_buttons.dart';
import 'package:flutter/material.dart';

class MainLogMobilePage extends StatefulWidget {
  const MainLogMobilePage({
    required this.onLoggerClose,
    super.key,
  });

  final VoidCallback onLoggerClose;

  static void cleanLogs({bool clearDB = false}) {
    LogManager.instance.clean(cleanDB: clearDB);
  }

  static void cleanHttpLogs() {
    HttpLogManager.instance.cleanAllLogs(cleanDB: true);
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
  _MainLogMobilePageState createState() => _MainLogMobilePageState();
}

class _MainLogMobilePageState extends State<MainLogMobilePage> {
  final _pageController = PageController();
  final _logsMode = LogsModeController.instance.logMode;

  final _popupKey = GlobalKey<PopupMenuButtonState>();
  final _navKey = GlobalKey<OptionsButtonsState>();

  final _httpLogKey = GlobalKey<HttpLogsPageState>();
  final _debugLogKey = GlobalKey<LogPageState>();
  final _infoLogKey = GlobalKey<LogPageState>();
  final _errorLogKey = GlobalKey<LogPageState>();

  late List<Widget> tabPages;

  LogType _currentLogType = LogType.http;

  @override
  void initState() {
    super.initState();
    tabPages = [
      HttpLogsPage(key: _httpLogKey),
      LogPage(key: _debugLogKey, logType: LogType.debug),
      LogPage(key: _infoLogKey, logType: LogType.info),
      LogPage(key: _errorLogKey, logType: LogType.error),
    ];
    _pageController.addListener(_onPageChanged);
    LogManager.instance.logToastNotifier.addListener(_openLogDetails);
    WidgetsBinding.instance.addPostFrameCallback((_) => _openLogDetails());
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    LogManager.instance.logToastNotifier.removeListener(_openLogDetails);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: TestBenchHelper.instance.theme,
      child: Scaffold(
        backgroundColor: TestBenchColors.backgroundGrey,
        appBar: CRAppBar(
          titleWidget: ValueListenableBuilder(
            valueListenable: _logsMode,

            //ignore: prefer-trailing-comma
            builder: (_, __, ___) => Text(
              _logsMode.value.appBarTitle,
              style: CRStyle.subtitle1BlackSemiBold17,
            ),
          ),
          onBackPressed: widget.onLoggerClose,
          showBackButton: true,
          actions: [
            PopupMenu(
              popupKey: _popupKey,
              child: IconButton(
                onPressed: () => _popupKey.currentState?.showButtonMenu(),
                icon: ImageExt.fromPackage(TestBenchAssets.assetsIcMenu),
              ),
            ),
          ],
        ),
        body: Container(
          color: TestBenchColors.backgroundGrey,
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    OptionsButtons(
                      key: _navKey,
                      titles: [
                        LogType.http.name,
                        LogType.debug.name,
                        LogType.info.name,
                        LogType.error.name,
                      ],
                      onSelected: _onOptionSelected,
                    ),
                    const SizedBox(height: 16),
                    MobileHeaderWidget(
                      onClear: _onClear,
                      onAllClear: _onAllClear,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: tabPages,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAllClear() {
    LogManager.instance.clean(cleanDB: _logsMode.value == LogsMode.fromDB);
    _updatePages();
  }

  void _onClear() {
    switch (_currentLogType) {
      case LogType.debug:
        LogManager.instance.cleanDebug();
        break;
      case LogType.info:
        LogManager.instance.cleanInfo();
        break;
      case LogType.error:
        LogManager.instance.cleanError();
        break;
      case LogType.http:
        HttpLogManager.instance.cleanHTTP();
        break;
    }
    _updatePages();
  }

  void _updatePages() {
    doPostFrame(() {
      (tabPages[_currentLogType.index].key as GlobalKey)
          .currentState
          // ignore: no-empty-block
          ?.setState(() {});
    });
  }

  void _onPageChanged() {
    _currentLogType = LogType.values[_pageController.page?.round() ?? 0];
    _navKey.currentState?.change(_currentLogType.index);
  }

  void _onOptionSelected(int index) {
    _currentLogType = LogType.values[index];
    _pageController.jumpToPage(index);
  }

  /// Opens a tab according to the type of log
  /// Opens the log details page
  Future<void> _openLogDetails() async {
    final log = LogManager.instance.logToastNotifier.value;
    final logType = log?.type;

    if (logType != null && log != null) {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (ctx) => LogLocalDetailPage(
            logBean: log,
            logType: logType,
          ),
        ),
        (Route<dynamic> route) => route.settings.name == '/',
      );

      _pageController.jumpToPage(logType.index);
      LogManager.instance.logToastNotifier.value = null;
    }
  }
}
