import 'package:enough_mail/enough_mail.dart';
import 'package:kmail_desktop/features/accounts/data/mail_account_config.dart';
import 'package:kmail_desktop/features/mail/data/mail_mime_mapper.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class MailService {
  Future<void> testImap(MailAccountConfig config, String password) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await _connectImap(client, config, password);
      await client.logout();
    } finally {
      await client.disconnect();
    }
  }

  Future<void> testSmtp(MailAccountConfig config, String password) async {
    final client = SmtpClient('kmail', isLogEnabled: false);
    try {
      await _connectSmtp(client, config, password);
      await client.quit();
    } finally {
      await client.disconnect();
    }
  }

  Future<List<EmailMessage>> fetchRecentMessages(
    MailAccountConfig config,
    String password, {
    required MailFolder folder,
    int limit = 50,
  }) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await _connectImap(client, config, password);
      final mailbox = await _selectMailbox(client, folder);
      if (mailbox == null) {
        await client.logout();
        return const [];
      }
      final total = mailbox.messagesExists;
      if (total == 0) {
        await client.logout();
        return const [];
      }
      final start = total > limit ? total - limit + 1 : 1;
      final sequence = MessageSequence.fromRange(start, total);
      final fetch = await client.fetchMessages(sequence, '(FLAGS UID ENVELOPE RFC822.SIZE BODY.PEEK[])');
      final mailboxPath = mailbox.path;
      final messages = fetch.messages.reversed
          .map((m) => MailMimeMapper.fromMime(m, accountId: config.id, folder: folder).copyWith(remoteMailbox: mailboxPath))
          .toList();
      await client.logout();
      return messages;
    } finally {
      await client.disconnect();
    }
  }

  Future<void> setSeen(MailAccountConfig config, String password, {required int uid, required String mailboxPath, required bool seen}) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await _connectImap(client, config, password);
      await client.selectMailboxByPath(mailboxPath);
      await client.uidStore(MessageSequence.fromId(uid), seen ? [MessageFlags.seen] : [MessageFlags.seen], action: seen ? StoreAction.add : StoreAction.remove);
      await client.logout();
    } finally { await client.disconnect(); }
  }

  Future<void> setFlagged(MailAccountConfig config, String password, {required int uid, required String mailboxPath, required bool flagged}) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await _connectImap(client, config, password);
      await client.selectMailboxByPath(mailboxPath);
      await client.uidStore(MessageSequence.fromId(uid), [MessageFlags.flagged], action: flagged ? StoreAction.add : StoreAction.remove);
      await client.logout();
    } finally { await client.disconnect(); }
  }

  Future<void> moveMessage(MailAccountConfig config, String password, {required int uid, required String fromMailboxPath, required MailFolder toFolder}) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await _connectImap(client, config, password);
      await client.selectMailboxByPath(fromMailboxPath);
      final boxes = await client.listMailboxes();
      final dest = _resolveMailbox(boxes, toFolder);
      final destPath = dest?.path ?? switch(toFolder){MailFolder.trash=>'Trash',MailFolder.archive=>'Archive',MailFolder.spam=>'Junk',MailFolder.inbox=>'INBOX',MailFolder.sent=>'Sent',MailFolder.drafts=>'Drafts',MailFolder.custom=>'INBOX'};
      await client.uidMove(MessageSequence.fromId(uid), destPath);
      await client.logout();
    } finally { await client.disconnect(); }
  }

  Future<void> deleteMessage(MailAccountConfig config, String password, {required int uid, required String mailboxPath}) async {
    final client = ImapClient(isLogEnabled: false);
    try {
      await _connectImap(client, config, password);
      await client.selectMailboxByPath(mailboxPath);
      await client.uidStore(MessageSequence.fromId(uid), [MessageFlags.deleted], action: StoreAction.add);
      await client.expunge();
      await client.logout();
    } finally { await client.disconnect(); }
  }

  Future<void> sendMessage(MailAccountConfig config, String password, MimeMessage message) async {
    final client = SmtpClient('kmail', isLogEnabled: false);
    try {
      await _connectSmtp(client, config, password);
      await client.sendMessage(message);
      await client.quit();
    } finally {
      await client.disconnect();
    }
  }

  Future<void> _connectImap(ImapClient client, MailAccountConfig config, String password) async {
    final isSecure = config.imapSecurity == MailSecurity.sslTls;
    await _connectServer(client, config.imapHost, config.imapPort, isSecure);
    if (config.imapSecurity == MailSecurity.startTls) {
      await client.startTls();
    }
    await client.login(config.username, password);
  }

  Future<void> _connectSmtp(SmtpClient client, MailAccountConfig config, String password) async {
    final isSecure = config.smtpSecurity == MailSecurity.sslTls;
    await _connectServer(client, config.smtpHost, config.smtpPort, isSecure);
    await client.ehlo();
    if (config.smtpSecurity == MailSecurity.startTls) {
      await client.startTls();
    }
    await client.authenticate(config.username, password, AuthMechanism.plain);
  }

  Future<void> _connectServer(dynamic client, String host, int port, bool isSecure) async {
    final fn = client.connectToServer as Function;
    try {
      await Function.apply(fn, [host, port], {#isSecure: isSecure});
    } catch (_) {
      await Function.apply(fn, [host], {#port: port, #isSecure: isSecure});
    }
  }

  Future<Mailbox?> _selectMailbox(ImapClient client, MailFolder folder) async {
    try {
      final mailboxes = await client.listMailboxes();
      final mailbox = _resolveMailbox(mailboxes, folder);
      if (mailbox == null) return null;
      return await client.selectMailbox(mailbox);
    } catch (_) {
      final fallback = switch (folder) {
        MailFolder.inbox => 'INBOX',
        MailFolder.sent => 'Sent',
        MailFolder.drafts => 'Drafts',
        MailFolder.trash => 'Trash',
        MailFolder.spam => 'Junk',
        MailFolder.archive => 'Archive',
        MailFolder.custom => 'INBOX',
      };
      try {
        return await client.selectMailboxByPath(fallback);
      } catch (_) {
        return null;
      }
    }
  }

  Mailbox? _resolveMailbox(List<Mailbox> boxes, MailFolder folder) {
    bool hasFlag(Mailbox m, MailboxFlag flag) => m.flags.contains(flag);
    for (final box in boxes) {
      final match = switch (folder) {
        MailFolder.inbox => hasFlag(box, MailboxFlag.inbox) || box.name.toLowerCase() == 'inbox',
        MailFolder.sent => hasFlag(box, MailboxFlag.sent),
        MailFolder.drafts => hasFlag(box, MailboxFlag.drafts),
        MailFolder.trash => hasFlag(box, MailboxFlag.trash),
        MailFolder.spam => hasFlag(box, MailboxFlag.junk),
        MailFolder.archive => hasFlag(box, MailboxFlag.archive),
        MailFolder.custom => false,
      };
      if (match) return box;
    }
    final name = switch (folder) {
      MailFolder.inbox => 'inbox',
      MailFolder.sent => 'sent',
      MailFolder.drafts => 'drafts',
      MailFolder.trash => 'trash',
      MailFolder.spam => 'spam',
      MailFolder.archive => 'archive',
      MailFolder.custom => 'inbox',
    };
    for (final box in boxes) {
      final n = box.name.toLowerCase();
      if (n == name || n.contains(name)) return box;
    }
    return folder == MailFolder.inbox && boxes.isNotEmpty ? boxes.first : null;
  }
}
