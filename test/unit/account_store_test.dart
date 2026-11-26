import 'package:flutter_test/flutter_test.dart';
import 'package:kmail_desktop/features/accounts/data/account_store.dart';
import 'package:kmail_desktop/features/accounts/data/mail_account_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'AccountStore saves config without password and stores password securely',
      () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final creds = MemoryCredentialStorage();
    final store = AccountStore(prefs, creds);
    const account = MailAccountConfig(
      id: 'a1',
      displayName: 'Test',
      email: 'test@example.com',
      imapHost: 'imap.example.com',
      imapPort: 993,
      imapSecurity: MailSecurity.sslTls,
      smtpHost: 'smtp.example.com',
      smtpPort: 587,
      smtpSecurity: MailSecurity.startTls,
      username: 'test@example.com',
      isDefault: true,
    );

    await store.saveAccounts([account]);
    await store.savePassword('a1', 'secret');

    final loaded = await store.loadAccounts();
    expect(loaded, hasLength(1));
    expect(loaded.first.email, 'test@example.com');
    expect(await store.readPassword('a1'), 'secret');
    final raw = prefs.getString('accounts.v1') ?? '';
    expect(raw.contains('secret'), isFalse);
  });
}
