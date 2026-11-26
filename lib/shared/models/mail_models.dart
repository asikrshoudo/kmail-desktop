import 'package:flutter/foundation.dart';

enum MailFolder {
  inbox,
  drafts,
  sent,
  spam,
  trash,
  archive,
  custom,
}

enum MailboxView {
  allInboxes,
  starred,
  unread,
  inbox,
  drafts,
  sent,
  spam,
  trash,
}

enum AttachmentType { pdf, png, jpg, gif, webp, txt, csv, docx, xlsx, zip, html, unknown }

@immutable
class EmailAddress {
  const EmailAddress({required this.name, required this.email});
  final String name;
  final String email;
  String get display => name.isNotEmpty ? '$name <$email>' : email;
}

@immutable
class Attachment {
  const Attachment({required this.id, required this.name, required this.type, required this.sizeBytes, this.previewText});
  final String id;
  final String name;
  final AttachmentType type;
  final int sizeBytes;
  final String? previewText;
  String get extension => name.contains('.') ? name.split('.').last.toLowerCase() : '';
}

@immutable
class EmailMessage {
  const EmailMessage({
    required this.id,
    required this.accountId,
    required this.folder,
    required this.sender,
    required this.to,
    this.cc = const [],
    this.bcc = const [],
    required this.subject,
    required this.preview,
    required this.bodyPlainText,
    required this.bodyHtml,
    required this.date,
    this.isUnread = false,
    this.isStarred = false,
    this.labels = const [],
    this.attachments = const [],
    this.hasRemoteImages = false,
    this.isDraft = false,
  });

  final String id;
  final String accountId;
  final MailFolder folder;
  final EmailAddress sender;
  final List<EmailAddress> to;
  final List<EmailAddress> cc;
  final List<EmailAddress> bcc;
  final String subject;
  final String preview;
  final String bodyPlainText;
  final String bodyHtml;
  final DateTime date;
  final bool isUnread;
  final bool isStarred;
  final List<String> labels;
  final List<Attachment> attachments;
  final bool hasRemoteImages;
  final bool isDraft;

  bool get hasAttachments => attachments.isNotEmpty;

  EmailMessage copyWith({
    String? id,
    String? accountId,
    MailFolder? folder,
    EmailAddress? sender,
    List<EmailAddress>? to,
    List<EmailAddress>? cc,
    List<EmailAddress>? bcc,
    String? subject,
    String? preview,
    String? bodyPlainText,
    String? bodyHtml,
    DateTime? date,
    bool? isUnread,
    bool? isStarred,
    List<String>? labels,
    List<Attachment>? attachments,
    bool? hasRemoteImages,
    bool? isDraft,
  }) {
    return EmailMessage(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      folder: folder ?? this.folder,
      sender: sender ?? this.sender,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      subject: subject ?? this.subject,
      preview: preview ?? this.preview,
      bodyPlainText: bodyPlainText ?? this.bodyPlainText,
      bodyHtml: bodyHtml ?? this.bodyHtml,
      date: date ?? this.date,
      isUnread: isUnread ?? this.isUnread,
      isStarred: isStarred ?? this.isStarred,
      labels: labels ?? this.labels,
      attachments: attachments ?? this.attachments,
      hasRemoteImages: hasRemoteImages ?? this.hasRemoteImages,
      isDraft: isDraft ?? this.isDraft,
    );
  }
}

@immutable
class MailAccount {
  const MailAccount({required this.id, required this.name, required this.email, required this.colorValue, this.isDefault = false});
  final String id;
  final String name;
  final String email;
  final int colorValue;
  final bool isDefault;
}
