const int maxBlogPostContentLength = 5000;

String sanitizeBlogContent(String content) {
  final withoutScriptBlocks = content.replaceAll(
    RegExp(
      r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
      caseSensitive: false,
    ),
    '',
  );
  final withoutEventHandlers = withoutScriptBlocks.replaceAll(
    RegExp(
      "\\s+on[a-z]+\\s*=\\s*(?:\"[^\"]*\"|'[^']*'|[^\\s>]+)",
      caseSensitive: false,
    ),
    '',
  );
  final withoutJavascriptUrls = withoutEventHandlers.replaceAll(
    RegExp(r'\bjavascript\s*:', caseSensitive: false),
    '',
  );

  return withoutJavascriptUrls.trim();
}

String? validateBlogContent(String content) {
  final trimmed = content.trim();

  if (trimmed.isEmpty) {
    return 'Body cannot be empty';
  }

  if (trimmed.length > maxBlogPostContentLength) {
    return 'Body must be $maxBlogPostContentLength characters or less';
  }

  return null;
}
