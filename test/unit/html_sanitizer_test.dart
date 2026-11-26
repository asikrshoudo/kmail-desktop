import 'package:flutter_test/flutter_test.dart';
import 'package:kmail_desktop/features/reader/html/html_sanitizer.dart';

void main() {
  group('HtmlSanitizer', () {
    test('removes scripts and unsafe handlers', () {
      const input = '<div>Hello</div><script>alert(1)</script><img src="x" onerror="alert(1)">';
      final result = HtmlSanitizer.sanitize(input, allowRemoteImages: false);
      expect(result.html.toLowerCase(), isNot(contains('<script')));
      expect(result.html.toLowerCase(), isNot(contains('onerror')));
      expect(result.html, contains('Hello'));
    });

    test('blocks remote images by default', () {
      const input = '<p>Hi</p><img src="https://example.com/a.png" alt="photo">';
      final result = HtmlSanitizer.sanitize(input, allowRemoteImages: false);
      expect(result.hasRemoteImages, isTrue);
      expect(result.html.toLowerCase(), isNot(contains('<img')));
      expect(result.html, contains('Remote image blocked'));
    });

    test('allows remote images when explicitly enabled', () {
      const input = '<img src="https://example.com/a.png" alt="photo">';
      final result = HtmlSanitizer.sanitize(input, allowRemoteImages: true);
      expect(result.hasRemoteImages, isTrue);
      expect(result.html.toLowerCase(), contains('<img'));
    });

    test('blocks javascript and unsafe data links', () {
      expect(HtmlSanitizer.hasUnsafeUrl('javascript:alert(1)'), isTrue);
      expect(HtmlSanitizer.hasUnsafeUrl('data:text/html,<script>alert(1)</script>'), isTrue);
      expect(HtmlSanitizer.hasUnsafeUrl('https://example.com'), isFalse);
    });

    test('converts html to plain text fallback', () {
      const input = '<h1>Title</h1><p>Hello <strong>world</strong></p>';
      final text = HtmlSanitizer.toPlainText(input);
      expect(text, contains('Title'));
      expect(text, contains('Hello world'));
      expect(text, isNot(contains('<p>')));
    });
  });
}
