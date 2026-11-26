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
}
