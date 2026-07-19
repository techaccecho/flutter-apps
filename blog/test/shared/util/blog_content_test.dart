import 'package:blog/modules/blog/util/blog_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('blog_content utility tests', () {
    group('sanitizeBlogContent', () {
      test('trims leading and trailing whitespace', () {
        expect(sanitizeBlogContent('   some content   '), 'some content');
      });

      test('removes script blocks completely', () {
        const input = 'Hello <script>alert("hack");</script> World';
        expect(sanitizeBlogContent(input), 'Hello  World');
      });

      test('removes inline event handlers', () {
        const input = '<div onload="doSomething()" onclick=\'click()\' onmouseover=hover>Content</div>';
        expect(sanitizeBlogContent(input), '<div>Content</div>');
      });

      test('removes javascript protocol URLs', () {
        const input = '[Click Here](javascript:alert("XSS"))';
        expect(sanitizeBlogContent(input), '[Click Here](alert("XSS"))');
      });

      test('handles mixed content case-insensitively', () {
        const input = 'Hello <SCRIPT>bad()</SCRIPT> <a href="JAVASCRIPT:alert()">link</a>';
        expect(sanitizeBlogContent(input), 'Hello  <a href="alert()">link</a>');
      });
    });

    group('validateBlogContent', () {
      test('returns error for empty content', () {
        expect(validateBlogContent(''), 'Body cannot be empty');
        expect(validateBlogContent('   '), 'Body cannot be empty');
      });

      test('returns error for content exceeding maximum length', () {
        final longContent = 'a' * (maxBlogPostContentLength + 1);
        expect(
          validateBlogContent(longContent),
          'Body must be $maxBlogPostContentLength characters or less',
        );
      });

      test('returns null for valid content', () {
        expect(validateBlogContent('Valid blog post content'), isNull);
        expect(validateBlogContent('a' * maxBlogPostContentLength), isNull);
      });
    });
  });
}
