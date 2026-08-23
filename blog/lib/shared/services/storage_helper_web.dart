// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? getStorageItem(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}

void setStorageItem(String key, String value) {
  try {
    html.window.localStorage[key] = value;
  } catch (_) {
    // Ignore storage write errors in restricted contexts
  }
}

void removeStorageItem(String key) {
  try {
    html.window.localStorage.remove(key);
  } catch (_) {
    // Ignore storage errors
  }
}

void openInNewTab(String url) {
  try {
    html.window.open(url, '_blank');
  } catch (_) {
    // Fallback if popup blocked
  }
}
