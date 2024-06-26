import 'package:test_bench/test_bench.dart';
import 'package:test_bench/src/constants.dart';
import 'package:test_bench/src/res/colors.dart';
import 'package:test_bench/src/res/styles.dart';
import 'package:test_bench/src/widget/expand_arrow_button.dart';
import 'package:test_bench/src/widget/rounded_card.dart';
import 'package:flutter/material.dart';

class HeadersExpansionTile extends StatefulWidget {
  const HeadersExpansionTile({
    required this.headers,
    super.key,
  });

  final Map<String, dynamic>? headers;

  @override
  State<HeadersExpansionTile> createState() => _HeadersExpansionTileState();
}

class _HeadersExpansionTileState extends State<HeadersExpansionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final headersLength = widget.headers?.length ?? 0;

    return RoundedCard(
      padding: const EdgeInsets.only(
        left: 16,
        top: 10,
        right: 16,
        bottom: 10,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Headers',
                  style: CRStyle.subtitle1BlackSemiBold16,
                ),
              ),
              if (!_expanded)
                Text(
                  '$headersLength',
                  style: CRStyle.subtitle1BlackSemiBold16.copyWith(
                    color: TestBenchColors.grey,
                  ),
                ),
              const SizedBox(width: 6),
              ExpandArrowButton(
                isExpanded: _expanded,
                onTap: () => setState(() => _expanded = !_expanded),
              ),
            ],
          ),
          if (_expanded)
            ListView.separated(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: headersLength,
              shrinkWrap: true,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (_, index) {
                final header = widget.headers?.keys.elementAt(index);
                final value = widget.headers?.values.elementAt(index);

                return Row(children: [
                  Container(
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.purpleAccent.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$header:',
                      style: CRStyle.bodyBlackMedium14,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: TestBenchInitializer.instance.hiddenHeaders
                            .contains(header)
                        ? Row(children: [
                            Container(
                              decoration: BoxDecoration(
                                color: TestBenchColors.darkMagenta,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                kHidden.toString(),
                                style: CRStyle.bodyWhiteSemiBold14,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ])
                        : GestureDetector(
                            onLongPress: () =>
                                copyClipboard(context, value.toString()),
                            child: Text(
                              value.toString(),
                              style: CRStyle.bodyBlackRegular14,
                              textAlign: TextAlign.left,
                            ),
                          ),
                  ),
                ]);
              },
            ),
        ],
      ),
    );
  }
}
