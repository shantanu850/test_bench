import 'package:test_bench/test_bench.dart';
import 'package:test_bench/src/constants.dart';
import 'package:test_bench/src/models/request_status.dart';
import 'package:test_bench/src/res/colors.dart';
import 'package:test_bench/src/res/styles.dart';
import 'package:test_bench/src/widget/body_expansion_tile.dart';
import 'package:test_bench/src/widget/headers_expansion_tile.dart';
import 'package:test_bench/src/widget/params_expansion_tile.dart';
import 'package:test_bench/src/widget/url_value_widget.dart';
import 'package:flutter/material.dart';

class HttpRequestWidget extends StatefulWidget {
  const HttpRequestWidget(
    this.httpBean, {
    super.key,
  });

  final HttpBean httpBean;

  @override
  HttpRequestWidgetState createState() => HttpRequestWidgetState();
}

class HttpRequestWidgetState extends State<HttpRequestWidget>
    with AutomaticKeepAliveClientMixin {
  final _scrollCtrl = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final request = widget.httpBean.request;
    final response = widget.httpBean.response;
    final error = widget.httpBean.error;

    final status = widget.httpBean.status;
    final methodColor = request?.method == kMethodPost
        ? TestBenchColors.orange
        : TestBenchColors.green;
    final statusCode = response?.statusCode ?? error?.statusCode;

    return SingleChildScrollView(
      controller: _scrollCtrl,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: TestBenchColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  /// Request method
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          request?.method ?? '',
                          style: CRStyle.subtitle1BlackSemiBold16
                              .copyWith(color: methodColor),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'method',
                          style: CRStyle.captionGreyMedium12,
                        ),
                      ],
                    ),
                  ),

                  /// Request duration
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${response?.duration ?? error?.duration ?? 0}',
                          style: CRStyle.subtitle1BlackSemiBold16.copyWith(
                            color: _getColorByDuration(
                              response?.duration ?? error?.duration ?? 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          kMs,
                          style: CRStyle.captionGreyMedium12,
                        ),
                      ],
                    ),
                  ),

                  /// Request status
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (statusCode != null ||
                            status == RequestStatus.sending)
                          Text(
                            statusCode != null
                                ? statusCode.toString()
                                : kSending,
                            style: CRStyle.subtitle1BlackSemiBold16
                                .copyWith(color: status.color),
                          )
                        else
                          Icon(
                            status == RequestStatus.noInternet
                                ? Icons.wifi_off
                                : Icons.error,
                            color: status.color,
                            size: 18,
                          ),
                        const SizedBox(height: 6),
                        const Text(
                          'status',
                          style: CRStyle.captionGreyMedium12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            /// Headers
            HeadersExpansionTile(headers: request?.headers),
            const SizedBox(height: 12),

            /// URL
            UrlValueWidget(
              url: request?.url,
              requestTime: request?.requestTime,
              responseTime: response?.responseTime,
            ),
            const SizedBox(height: 12),

            /// Params
            ParamsExpansionTile(
              request: request,
            ),

            const SizedBox(height: 12),

            /// Body
            BodyExpansionTile(
              request: request,
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorByDuration(int duration) {
    if (duration < kMinDuration) {
      return TestBenchColors.green;
    } else if (duration < kAverageDuration) {
      return TestBenchColors.orange;
    } else {
      return TestBenchColors.red;
    }
  }
}
