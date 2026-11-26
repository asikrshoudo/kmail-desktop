import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:kmail_desktop/features/reader/html/html_sanitizer.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class AttachmentPreviewService {
  static Widget preview(Attachment attachment) {
    if (attachment.sizeBytes > 10 * 1024 * 1024) {
      return _unsupported('File is too large to preview safely in-app.', attachment);
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
        return _unsupported('PDF preview is not embedded yet. Use Save to open it in an external viewer.', attachment);
      case AttachmentType.docx:
      case AttachmentType.xlsx:
      case AttachmentType.zip:
      case AttachmentType.unknown:
        return _unsupported('Preview is not supported for this file type. You can save the file locally.', attachment);
    }
  }

  static Widget _imagePreview(Attachment attachment) {
    final bytes = attachment.bytes;
    if (bytes != null && bytes.isNotEmpty) {
      return Center(child: InteractiveViewer(child: Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain)));
    }
    final path = attachment.localPath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return Center(child: InteractiveViewer(child: Image.file(File(path), fit: BoxFit.contain)));
    }
    return _unsupported('Image bytes are not available for preview.', attachment);
  }

  static Widget _textPreview(Attachment attachment) {
    final text = attachment.previewText;
    if (text == null || text.isEmpty) {
      return _unsupported('No text content available for preview.', attachment);
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(child: SelectableText(text, style: const TextStyle(fontFamily: 'Consolas', height: 1.5))),
    );
  }

  static Widget _htmlPreview(Attachment attachment) {
    final html = attachment.previewText;
    if (html == null || html.isEmpty) {
      return _unsupported('No HTML content available for preview.', attachment);
    }
    final sanitized = HtmlSanitizer.sanitize(html, allowRemoteImages: false);
    return SingleChildScrollView(child: Html(data: sanitized.html));
  }

  static Widget _unsupported(String reason, Attachment attachment) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(border: Border.all(color: Colors.black12), borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.preview_outlined, size: 44),
            const SizedBox(height: 12),
            Text(attachment.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(reason, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
