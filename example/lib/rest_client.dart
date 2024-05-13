import 'dart:io';

import 'package:chopper/chopper.dart';
import 'package:test_bench/test_bench.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class RestClient {
  RestClient._() {
    dio = Dio()
      ..options.receiveTimeout = const Duration(milliseconds: _serverTimeout)
      ..options.connectTimeout = const Duration(milliseconds: _serverTimeout)
      ..options.sendTimeout = const Duration(milliseconds: _serverTimeout);

    dio.interceptors.add(
      TestBenchInitializer.instance.getDioInterceptor(),
    );
    chopper = ChopperClient(
      interceptors: [
        TestBenchInitializer.instance.getChopperInterceptor(),
      ],
    );
  }

  static const _serverTimeout = 15000;
  static final RestClient instance = RestClient._();

  late Dio dio;
  late ChopperClient chopper;

  /// Init proxy for Dio client.
  void initDioProxyForCharles(String proxy) {
    final split = proxy.split(':');
    final ip = split.first;
    final port = split[1];

    final proxyStr = 'PROXY $ip:$port; '
        'PROXY localhost:$port; DIRECT';
    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient(context: SecurityContext())
          ..findProxy = (uri) {
            return proxyStr;
          }
          ..badCertificateCallback = (
            X509Certificate cert,
            String host,
            int port,
          ) =>
              true;

        return client;
      };
    }
  }
}
