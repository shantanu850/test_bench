#include "include/test_bench/test_bench_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "test_bench_plugin.h"

void TestBenchPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  test_bench::TestBenchPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
