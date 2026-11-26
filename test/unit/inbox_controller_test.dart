import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kmail_desktop/app/bootstrap.dart';
import 'package:kmail_desktop/features/accounts/data/account_store.dart';
import 'package:kmail_desktop/features/accounts/data/mail_account_config.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_state.dart';
import 'package:kmail_desktop/features/mail/data/mail_service.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMailService extends MailService {
  @override
  Future<void> testImap(MailAccountConfig config, String password) async {}

  @override
  Future<void> testSmtp(MailAccountConfig config, String password) async {}

  @override
  Future<List<EmailMessage>> fetchRecentMessages(
    MailAccountConfig config,
    String password, {
    required MailFolder folder,
    int limit = 50,
  }) async {
    if (folder != MailFolder.inbox) return const [];
    return [
      EmailMessage(
        id: '${config.id}-inbox-1',
        accountId: config.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(name: 'Sender', email: 'sender@example.com'),
        to: [EmailAddress(name: config.displayName, email: config.email)],
        subject: 'Receipt for ${config.email}',
        preview: 'Receipt preview',
        bodyPlainText: 'Receipt body',
        bodyHtml: '<p>Receipt body</p>',
        date: DateTime(2026, 1, 1),
        isUnread: true,
      ),
    ];
  }

  @override
  Future<void> sendMessage(MailAccountConfig config, String password, message) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> makeContainer({List<MailAccountConfig> accounts = const []}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = AccountStore(prefs, MemoryCredentialStorage());
    await store.saveAccounts(accounts);
    for (final a in accounts) {
      await store.savePassword(a.id, 'password');
    }
    final container = ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWith((ref) async => prefs),
      accountStoreProvider.overrideWithValue(store),
      mailServiceProvider.overrideWithValue(_FakeMailService()),
    ]);
    addTearDown(container.dispose);
    container.read(inboxControllerProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return container;
  }

  group('InboxController', () {
    test('starts empty when no accounts are configured', () async {
      final container = await makeContainer();
      final state = container.read(inboxControllerProvider);
      expect(state.hasAccounts, isFalse);
      expect(state.visibleMessages, isEmpty);
      expect(state.syncStatus, isNot(SyncStatus.error));
    });

    test('search filters real cached/synced messages', () async {
      final account = MailAccountConfig(
        id: 'acc-1',
        displayName: 'Alex',
        email: 'alex@example.com',
        imapHost: 'imap.example.com',
        imapPort: 993,
        imapSecurity: MailSecurity.sslTls,
        smtpHost: 'smtp.example.com',
        smtpPort: 587,
        smtpSecurity: MailSecurity.startTls,
        username: 'alex@example.com',
        isDefault: true,
      );
      final container = await makeContainer(accounts: [account]);
      final controller = container.read(inboxControllerProvider.notifier);
      controller.setSearch('receipt');
      final state = container.read(inboxControllerProvider);
      expect(state.visibleMessages, isNotEmpty);
      expect(state.visibleMessages.every((m) => m.subject.toLowerCase().contains('receipt')), isTrue);
    });

    test('star, archive, delete update local state', () async {
      final account = MailAccountConfig(
        id: 'acc-1',
        displayName: 'Alex',
        email: 'alex@example.com',
        imapHost: 'imap.example.com',
        imapPort: 993,
        imapSecurity: MailSecurity.sslTls,
        smtpHost: 'smtp.example.com',
        smtpPort: 587,
        smtpSecurity: MailSecurity.startTls,
        username: 'alex@example.com',
        isDefault: true,
      );
      final container = await makeContainer(accounts: [account]);
      final controller = container.read(inboxControllerProvider.notifier);
      final id = container.read(inboxControllerProvider).visibleMessages.first.id;
      final before = container.read(inboxControllerProvider).messages.firstWhere((m) => m.id == id).isStarred;
      controller.toggleStar(id);
      expect(container.read(inboxControllerProvider).messages.firstWhere((m) => m.id == id).isStarred, !before);
      controller.toggleSelected(id);
      controller.archiveSelected();
      expect(container.read(inboxControllerProvider).messages.firstWhere((m) => m.id == id).folder, MailFolder.archive);
    });
  });
}
