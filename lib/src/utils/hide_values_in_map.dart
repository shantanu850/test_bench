import 'package:test_bench/test_bench.dart';
import 'package:test_bench/src/constants.dart';

Map hideValuesInMap(Map body) {
  return body.map((key, value) {
    if (TestBenchInitializer.instance.hiddenFields.contains(key)) {
      return MapEntry(key, kHidden);
    } else {
      if (value is Map) {
        return MapEntry(key, hideValuesInMap(value));
      }
      if (value is List) {
        final list = value.map((e) {
          return e is Map ? hideValuesInMap(e) : e;
        }).toList();

        return MapEntry(key, list);
      }

      return MapEntry(key, value);
    }
  });
}
