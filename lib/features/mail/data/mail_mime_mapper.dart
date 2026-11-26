import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class MailMimeMapper {
  static EmailMessage fromMime(
    MimeMessage mime, {
    required String accountId,
    required MailFolder folder,
  }) {
    final from = mime.from?.isNotEmpty == true ? mime.from!.first : null;
    final to = mime.to?.map(_addr).toList() ?? const <EmailAddress>[];
    final cc = mime.cc?.map(_addr).toList() ?? const <EmailAddress>[];
    final bcc = mime.bcc?.map(_addr).toList() ?? const <EmailAddress>[];
    final subject = mime.decodeSubject() ?? '(No subject)';
    final plain = mime.decodeTextPlainPart() ?? '';
    final html = mime.decodeTextHtmlPart() ?? '';
    final date = mime.decodeDate() ?? DateTime.now();
    final rawFlags = (mime.flags ?? const []).toList();
    final flagStrings = rawFlags.map((f) => f.toString()).join(' ').toLowerCase();
    final isUnread = !flagStrings.contains('seen');
    final isStarred = flagStrings.contains('flagged') || flagStrings.contains(r'lagged');
    final bodyPlain = plain.trim().isNotEmpty ? plain : _stripHtml(html);
    final bodyHtml = html.trim().isNotEmpty
        ? html
        : '<pre style="font-family:Segoe UI,Arial,sans-serif;white-space:pre-wrap">${_escape(bodyPlain)}</pre>';
    final preview = bodyPlain.replaceAll(RegExp(r'\s+'), ' ').trim();

    final attachments = <Attachment>[];
    final parts = mime.allPartsFlat;
    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];
      final dyn = part as dynamic;
      final String? name = dyn.decodeFileName() as String?;
      final String media = (dyn.mediaType?.text as String?)?.toLowerCase() ?? '';
      final ContentDisposition? disp =
          (dyn.contentDisposition?.disposition as ContentDisposition?);
      final bool isAttachment = disp == ContentDisposition.attachment ||
          (name != null &&
              name.isNotEmpty &&
              media != 'text/plain' &&
              media != 'text/html');
      if (!isAttachment) continue;
      final fname = name ?? 'attachment-$i';
      final type = _typeForName(fname);
      List<int>? bytes;
      String? previewText;
      try {
        if (type == AttachmentType.txt ||
            type == AttachmentType.csv ||
            type == AttachmentType.html) {
          previewText = dyn.decodeContentText() as String?;
        }
        if (type == AttachmentType.png ||
            type == AttachmentType.jpg ||
            type == AttachmentType.gif ||
            type == AttachmentType.webp ||
            type == AttachmentType.pdf) {
          final decoded = dyn.decodeContentBinary();
          if (decoded is List<int>) bytes = decoded;
        }
      } catch (_) {}
      attachments.add(Attachment(
        id: '${mime.guid ?? mime.sequenceId ?? i}-$i-${fname.hashCode}',
        name: fname,
        type: type,
        sizeBytes: bytes?.length ?? 0,
        previewText: previewText,
        bytes: bytes,
      ));
    }

    final Object? mimeIdRaw = (mime as dynamic).messageId;
    final String? mimeId = mimeIdRaw is String ? mimeIdRaw : null;
    final id = mime.guid ??
        mimeId ??
        '$accountId-${folder.name}-${date.microsecondsSinceEpoch}-${subject.hashCode}';

    return EmailMessage(
      id: id,
      accountId: accountId,
      folder: folder,
      sender: EmailAddress(
        name: from?.personalName ?? from?.email ?? 'Unknown',
        email: from?.email ?? 'unknown@unknown',
      ),
      to: to,
      cc: cc,
      bcc: bcc,
      subject: subject,
      preview: preview.length > 180 ? preview.substring(0, 180) : preview,
      bodyPlainText: bodyPlain,
      bodyHtml: bodyHtml,
      date: date,
      isUnread: isUnread,
      isStarred: isStarred,
      attachments: attachments,
      hasRemoteImages: RegExp(
        "<img\\b[^>]*src\\s*=\\s*[\"']https?:",
        caseSensitive: false,
      ).hasMatch(bodyHtml),
      isDraft: folder == MailFolder.drafts,
      remoteUid: mime.uid,
    );
  }

  static MailAddress _toMail(EmailAddress a) => MailAddress(a.name, a.email);

  static Future<MimeMessage> toMime(EmailMessage msg) async {
    final builder = MessageBuilder.prepareMultipartAlternativeMessage(
      plainText: msg.bodyPlainText,
      htmlText: msg.bodyHtml,
    )
      ..from = [_toMail(msg.sender)]
      ..to = msg.to.map(_toMail).toList()
      ..cc = msg.cc.map(_toMail).toList()
      ..bcc = msg.bcc.map(_toMail).toList()
      ..subject = msg.subject;
    for (final a in msg.attachments) {
      try {
        if (a.localPath != null && a.localPath!.isNotEmpty) {
          await builder.addFile(File(a.localPath!), MediaType.guessFromFileName(a.name));
        } else if (a.bytes != null) {
          final data = a.bytes!;
          builder.addBinary(
            data is Uint8List ? data : Uint8List.fromList(data),
            MediaType.guessFromFileName(a.name),
            filename: a.name,
          );
        }
      } catch (_) {}
    }
    return builder.buildMimeMessage();
  }

  static EmailAddress _addr(MailAddress a) {
    final name = a.personalName;
    final fallback = a.email.split('@').first;
    return EmailAddress(name: (name != null && name.isNotEmpty) ? name : fallback, email: a.email);
  }

  static AttachmentType _typeForName(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'pdf' => AttachmentType.pdf,
      'png' => AttachmentType.png,
      'jpg' || 'jpeg' => AttachmentType.jpg,
      'gif' => AttachmentType.gif,
      'webp' => AttachmentType.webp,
      'txt' || 'md' || 'log' => AttachmentType.txt,
      'csv' => AttachmentType.csv,
      'doc' || 'docx' => AttachmentType.docx,
      'xls' || 'xlsx' => AttachmentType.xlsx,
      'zip' || 'rar' || '7z' => AttachmentType.zip,
      'html' || 'htm' => AttachmentType.html,
      _ => AttachmentType.unknown,
    };
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _escape(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
