import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kmail_desktop/app/app.dart';
import 'package:kmail_desktop/app/bootstrap.dart';
import 'package:kmail_desktop/features/accounts/data/account_store.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/features/mail/data/mail_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeMailService extends MailService {}

void main() {
  testWidgets('Kmail app shell renders core panes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = AccountStore(prefs, MemoryCredentialStorage());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs),
          accountStoreProvider.overrideWithValue(store),
          mailServiceProvider.overrideWithValue(_FakeMailService()),
        ],
        child: const KmailApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kmail'), findsWidgets);
    expect(find.text('Compose'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });
}
