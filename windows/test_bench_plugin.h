#ifndef FLUTTER_PLUGIN_TEST_BENCH_PLUGIN_H_
#define FLUTTER_PLUGIN_TEST_BENCH_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace test_bench {

class TestBenchPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  TestBenchPlugin();

  virtual ~TestBenchPlugin();

  // Disallow copy and assign.
  TestBenchPlugin(const TestBenchPlugin&) = delete;
  TestBenchPlugin& operator=(const TestBenchPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace test_bench

#endif  // FLUTTER_PLUGIN_TEST_BENCH_PLUGIN_H_
