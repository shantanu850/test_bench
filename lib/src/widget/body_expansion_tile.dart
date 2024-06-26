import 'package:test_bench/test_bench.dart';
import 'package:test_bench/src/res/colors.dart';
import 'package:test_bench/src/res/styles.dart';
import 'package:test_bench/src/widget/expand_arrow_button.dart';
import 'package:test_bench/src/widget/json_widget/json_widget.dart';
import 'package:test_bench/src/widget/rounded_card.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BodyExpansionTile extends StatefulWidget {
  const BodyExpansionTile({
    required this.request,
    super.key,
  });

  final RequestBean? request;

  @override
  State<BodyExpansionTile> createState() => _BodyExpansionTileState();
}

class _BodyExpansionTileState extends State<BodyExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const _jsonWidgetBodyValueKey = ValueKey('RequestPageBody');
    final bodyIsString = widget.request?.body is String;
    final bodyLength =
        bodyIsString ? 1 : _tryGetBodyAsMap(widget.request)?.length ?? 0;
    final bodyIsNotEmpty = bodyLength != 0;

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
                  'Body',
                  style: CRStyle.subtitle1BlackSemiBold16,
                ),
              ),
              Text(
                '$bodyLength',
                style: CRStyle.subtitle1BlackSemiBold16.copyWith(
                  color: TestBenchColors.grey,
                ),
              ),
              const SizedBox(width: 6),
              ExpandArrowButton(
                isExpanded: _isExpanded && bodyIsNotEmpty,
                onTap: bodyIsNotEmpty ? _expand : null,
              ),
            ],
          ),
          if (bodyIsNotEmpty && !bodyIsString)
            JsonWidget(
              _tryGetBodyAsMap(widget.request),
              allExpandedNodes: _isExpanded,
              key: _jsonWidgetBodyValueKey,
            ),
          if (bodyIsString && _isExpanded) Text(widget.request?.body),
        ],
      ),
    );
  }

  Map<String, dynamic>? _tryGetBodyAsMap(request) {
    if (request?.body is FormData) {
      return request?.getFormData() ?? '';
    } else if (request?.body is List) {
      return request?.body ?? '';
    } else if (request?.body is Map<String, dynamic>) {
      return request?.body ?? '';
    } else {
      return null;
    }
  }

  void _expand() => setState(() => _isExpanded = !_isExpanded);
}
