import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

class MockStorage {
  static final Map<String, String> _store = {};

  static String? getItem(String key) => _store[key];
  static void setItem(String key, String value) => _store[key] = value;
  static void clear() => _store.clear();
}

class TestUrlEmbedResolver {
  static const String guestUserIdKey = 'wordsearch_guest_user_id';

  static String _generateUuid() {
    final random = Random();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // v4
    values[8] = (values[8] & 0x3f) | 0x80; // variant
    return [
      values.sublist(0, 4).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      values.sublist(4, 6).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      values.sublist(6, 8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      values.sublist(8, 10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      values.sublist(10, 16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
    ].join('-');
  }

  static String getEffectiveUserId(String? authenticatedUserId) {
    if (authenticatedUserId != null && authenticatedUserId.isNotEmpty) {
      return authenticatedUserId;
    }

    final storedGuestId = MockStorage.getItem(guestUserIdKey);
    if (storedGuestId != null && storedGuestId.isNotEmpty) {
      return storedGuestId;
    }

    final newGuestId = 'guest_${_generateUuid()}';
    MockStorage.setItem(guestUserIdKey, newGuestId);
    return newGuestId;
  }

  static String resolveUrl(String rawUrl, {String? userId, String puzzleBaseUrl = 'http://localhost:3005'}) {
    var url = rawUrl.trim();
    final isWordSearch = url.contains('/wordsearch') || url.contains('wordsearch.html');

    if (isWordSearch) {
      if (url.startsWith('/')) {
        url = '$puzzleBaseUrl$url';
      }

      final effectiveUserId = getEffectiveUserId(userId);

      if (url.contains(RegExp(r'userId=[^&]+'))) {
        url = url.replaceAll(
          RegExp(r'userId=[^&]+'),
          'userId=${Uri.encodeComponent(effectiveUserId)}',
        );
      } else {
        final separator = url.contains('?') ? '&' : '?';
        url = '$url${separator}userId=${Uri.encodeComponent(effectiveUserId)}';
      }
    }

    return url;
  }
}

void main() {
  setUp(() {
    MockStorage.clear();
  });

  group('UrlEmbedBuilder Local Storage & UUID Resolution Tests', () {
    test('reuses existing guest userId from local storage if present', () {
      const existingStoredGuest = 'guest_e4d909c2-90f7-4185-b062-790176d655f4';
      MockStorage.setItem(TestUrlEmbedResolver.guestUserIdKey, existingStoredGuest);

      final input = 'https://puzzle-apps.vercel.app/wordsearch/puzzle';
      final resolved = TestUrlEmbedResolver.resolveUrl(input, userId: null);

      expect(resolved, 'https://puzzle-apps.vercel.app/wordsearch/puzzle?userId=guest_e4d909c2-90f7-4185-b062-790176d655f4');
    });

    test('generates and persists a new guest UUID into local storage if storage is empty', () {
      expect(MockStorage.getItem(TestUrlEmbedResolver.guestUserIdKey), isNull);

      final input = 'https://puzzle-apps.vercel.app/wordsearch/puzzle';
      final resolved = TestUrlEmbedResolver.resolveUrl(input, userId: null);

      final storedValue = MockStorage.getItem(TestUrlEmbedResolver.guestUserIdKey);
      expect(storedValue, isNotNull);
      expect(storedValue!.startsWith('guest_'), isTrue);
      expect(resolved, 'https://puzzle-apps.vercel.app/wordsearch/puzzle?userId=${Uri.encodeComponent(storedValue)}');
    });

    test('prefers authenticated userId over local storage guest ID when user is logged in', () {
      MockStorage.setItem(TestUrlEmbedResolver.guestUserIdKey, 'guest_old_session');

      final input = 'https://puzzle-apps.vercel.app/wordsearch/puzzle';
      final resolved = TestUrlEmbedResolver.resolveUrl(input, userId: 'auth0|player_main');

      expect(resolved, 'https://puzzle-apps.vercel.app/wordsearch/puzzle?userId=auth0%7Cplayer_main');
    });

    test('does NOT append userId or interact with storage for non-wordsearch embeds', () {
      final youtube = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      expect(TestUrlEmbedResolver.resolveUrl(youtube, userId: null), youtube);
      expect(MockStorage.getItem(TestUrlEmbedResolver.guestUserIdKey), isNull);
    });
  });
}
