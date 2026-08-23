final Map<String, String> _memoryStorage = {};

String? getStorageItem(String key) {
  return _memoryStorage[key];
}

void setStorageItem(String key, String value) {
  _memoryStorage[key] = value;
}

void openInNewTab(String url) {
  // Stub for non-web environments and tests
}
