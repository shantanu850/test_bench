import 'package:test_bench/src/constants.dart';
import 'package:test_bench/src/test_bench_helper.dart';
import 'package:test_bench/src/js/console_output_worker.dart';
import 'package:test_bench/src/js/scripts.dart';
import 'package:test_bench/src/utils/html_stub.dart'
    if (dart.library.js) 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:worker_manager/worker_manager.dart';

final class ConsoleLogOutput extends LogOutput {
  ConsoleLogOutput() {
    if (kIsWeb) {
      _createWorker();
    }
  }

  @override
  Future<void> output(OutputEvent event) async {
    await TestBenchHelper.instance.lock.synchronized(() async {
      if (kIsWeb) {
        if (kReleaseMode || kProfileMode) {
          final src = html.ScriptElement()..text = printLogsScript;
          html.document.body?.append(src);
          printLogs(event.lines);
          src.remove();
        } else {
          // ignore: avoid_print
          event.lines.forEach(print);
        }
      } else {
        await workerManager.execute(() async => isolatePrintLog(event.lines));
      }
    });
  }

  void _createWorker() {
    final srcWorker = html.ScriptElement()
      ..id = kWorkerId
      ..text = workerScript;
    html.document.body?.append(srcWorker);
    final srcCreateWorker = html.ScriptElement()..text = createWorkerScript;
    html.document.body?.append(srcCreateWorker);
  }
}

Object isolatePrintLog(dynamic data) {
  if (data is List) {
    // ignore: avoid_print
    data.forEach(print);
  }

  return '';
}
