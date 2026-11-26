import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kmail_desktop/app/app.dart';
import 'package:kmail_desktop/app/bootstrap.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Kmail app shell renders core panes', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWith((ref) async => prefs)
        ],
        child: const KmailApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kmail'), findsWidgets);
    expect(find.text('Compose'), findsOneWidget);
    expect(find.text('Inbox'), findsWidgets);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });
}
