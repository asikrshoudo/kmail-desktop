import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kmail_desktop/features/reader/html/html_sanitizer.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class AttachmentPreviewService {
  static Widget preview(Attachment attachment) {
    if (attachment.sizeBytes > 10 * 1024 * 1024) {
      return _unsupported(
          'File is too large to preview in this Phase 1 foundation.',
          attachment);
    }
    switch (attachment.type) {
      case AttachmentType.png:
      case AttachmentType.jpg:
      case AttachmentType.gif:
      case AttachmentType.webp:
        return _imagePreview(attachment);
      case AttachmentType.txt:
      case AttachmentType.csv:
        return _textPreview(attachment);
      case AttachmentType.html:
        return _htmlPreview(attachment);
      case AttachmentType.pdf:
        return _unsupported(
            'PDF rendering is planned/integration-dependent on Windows CI. A safe fallback is shown in Phase 1.',
            attachment);
      case AttachmentType.docx:
      case AttachmentType.xlsx:
      case AttachmentType.zip:
      case AttachmentType.unknown:
        return _unsupported(
            'Preview is not supported for this file type in Phase 1.',
            attachment);
    }
  }

  static Widget _imagePreview(Attachment attachment) {
    // Mock image preview: use placeholder generated visuals to avoid bundling binary assets.
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 520,
            height: 340,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade200, Colors.blueGrey.shade50]),
              border: Border.all(color: Colors.black12),
            ),
            child: const Center(child: Icon(Icons.image_outlined, size: 72)),
          ),
          const SizedBox(height: 12),
          Text('${attachment.name} • mock image preview'),
        ],
      ),
    );
  }

  static Widget _textPreview(Attachment attachment) {
    final text = attachment.previewText ??
        'No preview text available for this mock attachment.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
          child: SelectableText(text,
              style: const TextStyle(fontFamily: 'Consolas', height: 1.5))),
    );
  }

  static Widget _htmlPreview(Attachment attachment) {
    final html =
        attachment.previewText ?? '<p>HTML attachment preview unavailable.</p>';
    final sanitized = HtmlSanitizer.sanitize(html, allowRemoteImages: false);
    return SingleChildScrollView(child: Html(data: sanitized.html));
  }

  static Widget _unsupported(String reason, Attachment attachment) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.preview_outlined, size: 44),
            const SizedBox(height: 12),
            Text(attachment.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(reason, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            const Text('Save/download is planned for a future phase.'),
          ],
        ),
      ),
    );
  }
}
