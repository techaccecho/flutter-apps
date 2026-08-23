import 'package:blog/shared/services/storage_helper_stub.dart'
    if (dart.library.html) 'package:blog/shared/services/storage_helper_web.dart'
    as storage_impl;

class StorageHelper {
  static const String guestUserIdKey = 'wordsearch_guest_user_id';

  static String? getItem(String key) => storage_impl.getStorageItem(key);

  static void setItem(String key, String value) =>
      storage_impl.setStorageItem(key, value);

  static void removeItem(String key) =>
      storage_impl.removeStorageItem(key);

  static void openInNewTab(String url) => storage_impl.openInNewTab(url);
}
