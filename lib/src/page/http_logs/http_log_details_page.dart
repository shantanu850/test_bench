import 'package:test_bench/src/test_bench_helper.dart';
import 'package:test_bench/src/data/bean/http_bean.dart';
import 'package:test_bench/src/dio_log.dart';
import 'package:test_bench/src/models/http_log_type.dart';
import 'package:test_bench/src/res/colors.dart';
import 'package:test_bench/src/widget/cr_app_bar.dart';
import 'package:test_bench/src/widget/options_buttons.dart';
import 'package:flutter/material.dart';

///Network Request Details
class HttpLogDetailsPage extends StatefulWidget {
  const HttpLogDetailsPage(
    this.netOptions, {
    this.isWeb = false,
    super.key,
  });

  final HttpBean netOptions;
  final bool isWeb;

  @override
  _HttpLogDetailsPageState createState() => _HttpLogDetailsPageState();
}

class _HttpLogDetailsPageState extends State<HttpLogDetailsPage>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  final _navKey = GlobalKey<OptionsButtonsState>();

  int currentIndex = 0;

  /// Global keys for all expanded nodes
  final _requestPageGlobalKey = GlobalKey<HttpRequestWidgetState>();
  final _responsePageGlobalKey = GlobalKey<HttpResponseWidgetState>();

  HttpLogType _currentLogType = HttpLogType.request;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: TestBenchHelper.instance.theme,
      child: Scaffold(
        backgroundColor: TestBenchColors.backgroundGrey,
        appBar: widget.isWeb ? null : const CRAppBar(title: 'Http log'),
        body: Column(
          children: [
            Container(
              color: TestBenchColors.backgroundGrey,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OptionsButtons(
                key: _navKey,
                titles: [
                  HttpLogType.request.asString(),
                  HttpLogType.response.asString(),
                  HttpLogType.error.asString(),
                ],
                onSelected: _onPageSelected,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView(
                controller: _pageController,
                children: [
                  HttpRequestWidget(
                    widget.netOptions,
                    key: _requestPageGlobalKey,
                  ),
                  HttpResponseWidget(
                    widget.netOptions,
                    key: _responsePageGlobalKey,
                  ),
                  HttpErrorWidget(widget.netOptions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged() {
    _currentLogType = HttpLogType.values[_pageController.page?.round() ?? 0];
    _navKey.currentState?.change(_currentLogType.index);
  }

  void _onPageSelected(int index) {
    _currentLogType = HttpLogType.values[index];
    _pageController.jumpToPage(index);
  }
}
