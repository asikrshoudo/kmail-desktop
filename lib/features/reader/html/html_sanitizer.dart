class SanitizedHtml {
  const SanitizedHtml({required this.html, required this.hasRemoteImages});
  final String html;
  final bool hasRemoteImages;
}

class HtmlSanitizer {
  static final RegExp _scriptTag = RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false, dotAll: true);
  static final RegExp _styleTag = RegExp(r'<style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style>', caseSensitive: false, dotAll: true);
  static final RegExp _iframeTag = RegExp(r'<iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe>|<iframe\b[^>]*\/?>', caseSensitive: false, dotAll: true);
  static final RegExp _objectTag = RegExp(r'<object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object>', caseSensitive: false, dotAll: true);
  static final RegExp _embedTag = RegExp(r'<embed\b[^>]*>', caseSensitive: false);
  static final RegExp _formTag = RegExp(r'<form\b[^<]*(?:(?!<\/form>)<[^<]*)*<\/form>', caseSensitive: false, dotAll: true);
  static final RegExp _eventHandlers = RegExp('''\\son\\w+\\s*=\\s*(?:"[^"]*"|'[^']*'|[^\\s>]+)''', caseSensitive: false);
  static final RegExp _jsHref = RegExp('''(href|src)\\s*=\\s*(?:"\\s*(javascript|data):[^"]*"|'\\s*(javascript|data):[^']*')''', caseSensitive: false);
  static final RegExp _remoteImg = RegExp('''<img\\b([^>]*?)src\\s*=\\s*("http[^"]*"|'http[^']*')([^>]*)>''', caseSensitive: false, dotAll: true);

  static SanitizedHtml sanitize(String input, {required bool allowRemoteImages}) {
    var html = input;
    var hasRemoteImages = false;

    html = html.replaceAll(_scriptTag, '');
    html = html.replaceAll(_styleTag, '');
    html = html.replaceAll(_iframeTag, '');
    html = html.replaceAll(_objectTag, '');
    html = html.replaceAll(_embedTag, '');
    html = html.replaceAll(_formTag, '');
    html = html.replaceAll(_eventHandlers, '');
    html = html.replaceAllMapped(_jsHref, (m) => '${m.group(1)}="#"');

    html = html.replaceAllMapped(_remoteImg, (m) {
      hasRemoteImages = true;
      if (allowRemoteImages) return m.group(0)!;
      final before = m.group(1) ?? '';
      final after = m.group(3) ?? '';
      final altMatch = RegExp('''alt\\s*=\\s*("([^"]*)"|'([^']*)')''', caseSensitive: false).firstMatch('$before $after');
      final alt = altMatch?.group(2) ?? altMatch?.group(3) ?? 'Remote image blocked';
      return '<div style="padding:12px;border:1px solid #d9e2ec;border-radius:8px;color:#526071;background:#f5f7fa;font-size:13px">Remote image blocked: ${_escapeHtml(alt)}</div>';
    });

    // Basic guard for plain http/https/data image urls not caught in simple form.
    if (RegExp(r'<img\b[^>]*src\s*=\s*"https?:', caseSensitive: false).hasMatch(html) ||
        RegExp(r"<img\b[^>]*src\s*=\s*'https?:", caseSensitive: false).hasMatch(html)) {
      hasRemoteImages = true;
      if (!allowRemoteImages) {
        html = html.replaceAllMapped(RegExp(r'<img\b[^>]*>', caseSensitive: false), (m) {
          final tag = m.group(0)!;
          if (RegExp(r'''src\s*=\s*["']https?:''', caseSensitive: false).hasMatch(tag)) {
            return '<div style="padding:12px;border:1px solid #d9e2ec;border-radius:8px;color:#526071;background:#f5f7fa;font-size:13px">Remote image blocked.</div>';
          }
          return tag;
        });
      }
    }

    return SanitizedHtml(html: html, hasRemoteImages: hasRemoteImages);
  }

  static String toPlainText(String input) {
    var text = input;
    text = text.replaceAll(_scriptTag, ' ');
    text = text.replaceAll(_styleTag, ' ');
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'</p>|</div>|</li>|</tr>|</h\d>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n\s*\n+'), '\n\n');
    return text.trim();
  }

  static bool hasUnsafeUrl(String url) {
    final lower = url.trim().toLowerCase();
    return lower.startsWith('javascript:') || lower.startsWith('data:text/html');
  }

  static String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
