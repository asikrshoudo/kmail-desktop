import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kmail_desktop/features/mail/data/mail_mime_mapper.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

void main() {
  test('toMime builds a message with recipients and subject', () async {
    final msg = EmailMessage(
      id: '1',
      accountId: 'a1',
      folder: MailFolder.sent,
      sender: const EmailAddress(name: 'Me', email: 'me@example.com'),
      to: const [EmailAddress(name: 'You', email: 'you@example.com')],
      cc: const [EmailAddress(name: 'CC', email: 'cc@example.com')],
      subject: 'Hello',
      preview: 'Body',
      bodyPlainText: 'Body',
      bodyHtml: '<p>Body</p>',
      date: DateTime(2026, 1, 1),
    );

    final mime = await MailMimeMapper.toMime(msg);
    expect(mime.decodeSubject(), 'Hello');
    expect(mime.to?.first.email, 'you@example.com');
    expect(mime.cc?.first.email, 'cc@example.com');
    expect(mime.from?.first.email, 'me@example.com');
  });

  test('fromMime maps a plain rfc822 message without throwing', () {
    const raw = 'From: "Alice Example" <alice@example.com>\r\n'
        'To: bob@example.com\r\n'
        'Subject: Hello plain\r\n'
        'Date: Mon, 27 Oct 2026 10:00:00 +0000\r\n'
        'Message-ID: <hello-1@example.com>\r\n'
        'MIME-Version: 1.0\r\n'
        'Content-Type: text/plain; charset=utf-8\r\n'
        '\r\n'
        'Hello plain body\r\n';
    final mime = MimeMessage.parseFromText(raw);
    final msg = MailMimeMapper.fromMime(
      mime,
      accountId: 'a1',
      folder: MailFolder.inbox,
    );

    expect(msg.subject, 'Hello plain');
    expect(msg.bodyPlainText, contains('Hello plain body'));
    expect(msg.attachments, isEmpty);
  });

  test('fromMime maps a message with an attachment without throwing', () {
    const raw = 'From: "Alice Example" <alice@example.com>\r\n'
        'To: bob@example.com\r\n'
        'Subject: Hello with attachment\r\n'
        'Date: Mon, 27 Oct 2026 10:00:00 +0000\r\n'
        'Message-ID: <hello-2@example.com>\r\n'
        'MIME-Version: 1.0\r\n'
        'Content-Type: multipart/mixed; boundary="unique-boundary-1"\r\n'
        '\r\n'
        'This is a preamble.\r\n'
        '--unique-boundary-1\r\n'
        'Content-Type: text/plain; charset=utf-8\r\n'
        '\r\n'
        'See attached report.\r\n'
        '--unique-boundary-1\r\n'
        'Content-Type: application/pdf; name="report.pdf"\r\n'
        'Content-Disposition: attachment;\r\n'
        ' filename="report.pdf"\r\n'
        'Content-Transfer-Encoding: base64\r\n'
        '\r\n'
        'JVBERi0xLjQK\r\n'
        '--unique-boundary-1--\r\n';
    final mime = MimeMessage.parseFromText(raw);
    final msg = MailMimeMapper.fromMime(
      mime,
      accountId: 'a1',
      folder: MailFolder.inbox,
    );

    expect(msg.subject, 'Hello with attachment');
    expect(msg.bodyPlainText, contains('See attached report.'));
    expect(msg.attachments, isNotEmpty);
    expect(msg.attachments.first.name, 'report.pdf');
  });
}
