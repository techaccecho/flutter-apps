//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <auth0_flutter/auth0_flutter_plugin_c_api.h>
#include <flutter_inappwebview_windows/flutter_inappwebview_windows_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  Auth0FlutterPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("Auth0FlutterPluginCApi"));
  FlutterInappwebviewWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterInappwebviewWindowsPluginCApi"));
}
