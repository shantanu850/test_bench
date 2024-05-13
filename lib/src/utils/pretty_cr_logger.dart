import 'dart:convert';
import 'dart:math' as math;

import 'package:test_bench/src/constants.dart';
import 'package:test_bench/src/test_bench_helper.dart';
import 'package:test_bench/src/data/bean/error_bean.dart';
import 'package:test_bench/src/data/bean/request_bean.dart';
import 'package:test_bench/src/data/bean/response_bean.dart';
import 'package:test_bench/src/js/console_output_worker.dart';
import 'package:test_bench/src/js/error_worker_scripts.dart';
import 'package:test_bench/src/js/http_pretty_output_scripts.dart';
import 'package:test_bench/src/js/request_worker_scripts.dart';
import 'package:test_bench/src/js/response_worker_scripts.dart';
import 'package:test_bench/src/utils/html_stub.dart'
    if (dart.library.js) 'dart:html' as html;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:worker_manager/worker_manager.dart';

// ignore_for_file: member-ordering-extended
final class PrettyTestBench {
  PrettyTestBench() {
    if (kIsWeb) {
      _createRequestWorker();
      _createResponseWorker();
      _createErrorWorker();
    }
  }

  /// InitialTab count to logPrint json response
  static const int initialTab = 1;

  /// 1 tab length
  static String tabStep = '    ';

  /// Width size per logPrint
  static int maxWidth = 90;

  /// Log printer; defaults logPrint log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file.
  static void Function(Object object) logPrint = print;

  Future<void> onRequest(RequestBean requestBean) async {
    await TestBenchHelper.instance.lock.synchronized(() async {
      if (kIsWeb) {
        if (kReleaseMode || kProfileMode) {
          final src = html.ScriptElement()..text = printRequestLogScript;
          html.document.body?.append(src);
          final requestHeaders = <String, dynamic>{}
            ..addAll(requestBean.headers ?? <String, dynamic>{});
          requestHeaders['contentType'] = requestBean.contentType?.toString();
          requestHeaders['followRedirects'] = requestBean.followRedirects;
          requestHeaders['connectTimeout'] = requestBean.connectTimeout;
          requestHeaders['receiveTimeout'] = requestBean.receiveTimeout;
          printRequestLog(jsonEncode(requestBean
            ..headers = requestHeaders
            ..toJson()));
          src.remove();
        } else {
          _printRequest(requestBean);
        }
      } else {
        await workerManager.execute(() async =>
            isolatePrintRequest(requestBean..adaptForIsolatePrinting()));
      }
    });
  }

  Future<void> onError(ErrorBean errorBean) async {
    await TestBenchHelper.instance.lock.synchronized(() async {
      if (kIsWeb) {
        if (kReleaseMode || kProfileMode) {
          final src = html.ScriptElement()..text = printErrorLogScript;
          html.document.body?.append(src);
          final responseHeaders = <String, dynamic>{}
            ..addAll(errorBean.responseBean?.headers ?? <String, dynamic>{});

          printErrorLog(jsonEncode(errorBean
            ..responseBean?.headers = responseHeaders
            ..toJson()));
          src.remove();
        } else {
          _printError(errorBean);
        }
      } else {
        await workerManager.execute(() async => isolatePrintError(errorBean));
      }
    });
  }

  Future<void> onResponse(ResponseBean responseBean) async {
    await TestBenchHelper.instance.lock.synchronized(() async {
      if (kIsWeb) {
        if (kReleaseMode || kProfileMode) {
          final src = html.ScriptElement()..text = printResponseLogScript;
          html.document.body?.append(src);
          final responseHeaders = <String, dynamic>{}
            ..addAll(responseBean.headers ?? <String, dynamic>{});

          printResponseLog(jsonEncode(responseBean
            ..headers = responseHeaders
            ..toJson()));
          src.remove();
        } else {
          _printResponse(responseBean);
        }
      } else {
        await workerManager
            .execute(() async => isolatePrintResponse(responseBean));
      }
    });
  }

  Future<Object> isolatePrintRequest(dynamic requestBean) async {
    _printRequest(requestBean);
    // Return some result needed for pakage worker_manager.
    // If no result isolate job will crash when getting Null object in response
    // from isolate.

    return '';
  }

  Future<Object> isolatePrintResponse(dynamic responseBean) async {
    _printResponse(responseBean);
    // Return some result needed for pakage worker_manager.
    // If no result isolate job will crash when getting Null object in response
    // from isolate.

    return '';
  }

  void _createRequestWorker() {
    final srcBuffer = StringBuffer()
      ..writeln(printRequestHeaderScript)
      ..writeln(printBoxedScript)
      ..writeln(printKVScript)
      ..writeln(printBlockScript)
      ..writeln(printLineScript)
      ..writeln(printMapAsTableScript)
      ..writeln(requestWorkerScript);

    final srcWorker = html.ScriptElement()
      ..id = kRequestWorkerId
      ..text = srcBuffer.toString();
    html.document.body?.append(srcWorker);
    final srcCreateWorker = html.ScriptElement()
      ..text = createRequestWorkerScript;
    html.document.body?.append(srcCreateWorker);
  }

  void _createResponseWorker() {
    final srcBuffer = StringBuffer()
      ..writeln(printResponseHeaderScript)
      ..writeln(printBoxedScript)
      ..writeln(printKVScript)
      ..writeln(printBlockScript)
      ..writeln(printLineScript)
      ..writeln(printMapAsTableScript)
      ..writeln(indentScript)
      ..writeln(canFlattenMapScript)
      ..writeln(canFlattenListScript)
      ..writeln(printPrettyMapScript)
      ..writeln(printListScript)
      ..writeln(printResponseScript)
      ..writeln(responseWorkerScript);

    final srcWorker = html.ScriptElement()
      ..id = kResponseWorkerId
      ..text = srcBuffer.toString();
    html.document.body?.append(srcWorker);
    final srcCreateWorker = html.ScriptElement()
      ..text = createResponseWorkerScript;
    html.document.body?.append(srcCreateWorker);
  }

  void _createErrorWorker() {
    final srcBuffer = StringBuffer()
      ..writeln(printResponseHeaderScript)
      ..writeln(printBoxedScript)
      ..writeln(printKVScript)
      ..writeln(printBlockScript)
      ..writeln(printLineScript)
      ..writeln(printMapAsTableScript)
      ..writeln(indentScript)
      ..writeln(canFlattenMapScript)
      ..writeln(canFlattenListScript)
      ..writeln(printPrettyMapScript)
      ..writeln(printListScript)
      ..writeln(printResponseScript)
      ..writeln(errorWorkerScript);

    final srcWorker = html.ScriptElement()
      ..id = kErrorWorkerId
      ..text = srcBuffer.toString();
    html.document.body?.append(srcWorker);
    final srcCreateWorker = html.ScriptElement()
      ..text = createErrorWorkerScript;
    html.document.body?.append(srcCreateWorker);
  }
}

Future<Object> isolatePrintError(dynamic errorBean) async {
  _printError(errorBean);

  // Return some result needed for pakage worker_manager.
  // If no result isolate job will crash when getting Null object in response
  // from isolate.

  return '';
}

void _printRequest(RequestBean requestBean) {
  _printRequestHeader(requestBean);
  _printMapAsTable(requestBean.params, header: 'Query Parameters');
  final requestHeaders = <String, dynamic>{}
    ..addAll(requestBean.headers ?? <String, dynamic>{});
  requestHeaders['contentType'] = requestBean.contentType?.toString();
  requestHeaders['followRedirects'] = requestBean.followRedirects;
  requestHeaders['connectTimeout'] = requestBean.connectTimeout;
  requestHeaders['receiveTimeout'] = requestBean.receiveTimeout;
  _printMapAsTable(requestHeaders, header: 'Headers');

  if (requestBean.method != 'GET') {
    final dynamic data = requestBean.body;
    if (data != null) {
      if (data is Map) {
        _printMapAsTable(requestBean.body as Map?, header: 'Body');
      } else if (data is FormData) {
        final formDataMap = <String, dynamic>{}
          ..addEntries(data.fields)
          ..addEntries(data.files);
        _printMapAsTable(formDataMap, header: 'Form data | ${data.boundary}');
      } else {
        PrettyTestBench.logPrint('╔ Body ');
        _printBlock(data.toString());
      }
    }
  }
  _printLine('╚');
}

void _printResponse(ResponseBean responseBean) {
  _printResponseHeader(responseBean);
  _printMapAsTable(responseBean.headers, header: 'Headers');

  final responseData = responseBean.data;
  if (responseData != null) {
    PrettyTestBench.logPrint('╔ Body');
    PrettyTestBench.logPrint('║');
    if (responseData is Map) {
      _printPrettyMap(responseData);
    } else if (responseData is List) {
      PrettyTestBench.logPrint('║${_indent()}[');
      _printList(responseData);
      PrettyTestBench.logPrint('║${_indent()}[');
    } else {
      _printBlock(responseData.toString());
    }
    PrettyTestBench.logPrint('║');
  }

  _printLine('╚');
}

void _printError(ErrorBean errorBean) {
  if (errorBean.responseBean != null) {
    final uri = errorBean.url;
    _printBoxed(
      header:
          'Error ║ Status: ${errorBean.statusCode} ${errorBean.statusMessage}',
      text: uri.toString(),
    );
    if (errorBean.errorMessage != null && errorBean.responseBean != null) {
      final responseBean = errorBean.responseBean!;
      _printMapAsTable(responseBean.headers, header: 'Headers');
      PrettyTestBench.logPrint('╔ Body');
      PrettyTestBench.logPrint('║');
      if (responseBean.data != null) {
        if (responseBean.data is Map) {
          _printPrettyMap(responseBean.data as Map);
        } else if (responseBean.data is List) {
          PrettyTestBench.logPrint('║${_indent()}[');
          _printList(responseBean.data as List);
          PrettyTestBench.logPrint('║${_indent()}[');
        } else {
          _printBlock(responseBean.data.toString());
        }
      }
    }
    _printLine('╚');
    PrettyTestBench.logPrint('');
  } else {
    _printBoxed(
      header: 'Error ║ ',
      text: errorBean.errorMessage,
    );
  }
}

void _printPrettyMap(
  Map data, {
  int tabs = PrettyTestBench.initialTab,
  bool isListItem = false,
  bool isLast = false,
}) {
  var _tabs = tabs;
  final isRoot = _tabs == PrettyTestBench.initialTab;
  final initialIndent = _indent(_tabs);
  _tabs++;

  if (isRoot || isListItem) {
    PrettyTestBench.logPrint('║$initialIndent{');
  }

  data.keys.toList().asMap().forEach(
    (index, key) {
      final isLast = index == data.length - 1;
      dynamic value = data[key];
      if (value is String) {
        value = '"${value.toString().replaceAll(RegExp(r'(\r|\n)+'), " ")}"';
      }
      if (value is Map) {
        if (_canFlattenMap(value)) {
          PrettyTestBench.logPrint(
            '║${_indent(_tabs)} $key: $value${!isLast ? ',' : ''}',
          );
        } else {
          PrettyTestBench.logPrint('║${_indent(_tabs)} $key: {');
          _printPrettyMap(value, tabs: _tabs);
        }
      } else if (value is List) {
        if (_canFlattenList(value)) {
          PrettyTestBench.logPrint(
            '║${_indent(_tabs)} $key: ${value.toString()}',
          );
        } else {
          PrettyTestBench.logPrint('║${_indent(_tabs)} $key: [');
          _printList(value, tabs: _tabs);
          PrettyTestBench.logPrint('║${_indent(_tabs)} ]${isLast ? '' : ','}');
        }
      } else {
        final msg = value.toString().replaceAll('\n', '');
        final indent = _indent(_tabs);
        final linWidth = PrettyTestBench.maxWidth - indent.length;
        if (msg.length + indent.length > linWidth) {
          final lines = (msg.length / linWidth).ceil();
          for (var i = 0; i < lines; ++i) {
            var keyOrSpace = '  ';
            if (i == 0) {
              keyOrSpace = '$key: ';
            }
            PrettyTestBench.logPrint(
              '║${_indent(_tabs)} $keyOrSpace${msg.substring(i * linWidth, math.min<int>(i * linWidth + linWidth, msg.length))}',
            );
          }
        } else {
          PrettyTestBench.logPrint(
            '║${_indent(_tabs)} $key: $msg${!isLast ? ',' : ''}',
          );
        }
      }
    },
  );

  PrettyTestBench.logPrint(
    '║$initialIndent}${isListItem && !isLast ? ',' : ''}',
  );
}

String _indent([int tabCount = PrettyTestBench.initialTab]) =>
    PrettyTestBench.tabStep * tabCount;

bool _canFlattenList(List list) {
  return list.length < 10 && list.toString().length < PrettyTestBench.maxWidth;
}

bool _canFlattenMap(Map map) {
  return map.values.where((val) => val is Map || val is List).isEmpty &&
      map.toString().length < PrettyTestBench.maxWidth;
}

void _printList(List list, {int tabs = PrettyTestBench.initialTab}) {
  list.asMap().forEach(
    (i, e) {
      final isLast = i == list.length - 1;
      if (e is Map) {
        if (_canFlattenMap(e)) {
          PrettyTestBench.logPrint('║${_indent(tabs)}  $e${!isLast ? ',' : ''}');
        } else {
          _printPrettyMap(
            e,
            tabs: tabs + 1,
            isListItem: true,
            isLast: isLast,
          );
        }
      } else {
        PrettyTestBench.logPrint('║${_indent(tabs + 2)} $e${isLast ? '' : ','}');
      }
    },
  );
}

void _printBlock(String msg) {
  final lines = (msg.length / PrettyTestBench.maxWidth).ceil();
  for (var i = 0; i < lines; ++i) {
    PrettyTestBench.logPrint(
      (i >= 0 ? '║ ' : '') +
          msg.substring(
            i * PrettyTestBench.maxWidth,
            math.min<int>(
              i * PrettyTestBench.maxWidth + PrettyTestBench.maxWidth,
              msg.length,
            ),
          ),
    );
  }
}

void _printMapAsTable(Map? map, {String? header}) {
  if (map == null || map.isEmpty) {
    return;
  }
  PrettyTestBench.logPrint('╔ $header ');
  map.forEach((key, value) => _printKV(key.toString(), value));
}

void _printLine([String pre = '', String suf = '╝']) =>
    PrettyTestBench.logPrint('$pre${'═' * PrettyTestBench.maxWidth}$suf');

void _printRequestHeader(RequestBean requestBean) {
  final uri = requestBean.url;
  final method = requestBean.method;
  _printBoxed(header: 'Request ║ $method ', text: uri.toString());
}

void _printResponseHeader(ResponseBean responseBean) {
  final uri = responseBean.url;
  final method = responseBean.method;
  _printBoxed(
    header:
        'Response ║ $method ║ Status: ${responseBean.statusCode} ${responseBean.statusMessage} ',
    text: uri.toString(),
  );
}

void _printBoxed({String? header, String? text}) {
  PrettyTestBench.logPrint('');
  PrettyTestBench.logPrint('╔╣ $header');
  PrettyTestBench.logPrint('║  $text');
}

void _printKV(String? key, Object? v) {
  final pre = '╟ $key: ';
  final msg = v.toString();

  if (pre.length + msg.length > PrettyTestBench.maxWidth) {
    PrettyTestBench.logPrint(pre);
    _printBlock(msg);
  } else {
    PrettyTestBench.logPrint('$pre$msg');
  }
}
