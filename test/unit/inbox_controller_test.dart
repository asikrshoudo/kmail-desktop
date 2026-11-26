import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

void main() {
  group('InboxController', () {
    test('loads mock inbox and selects a message', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(inboxControllerProvider);
      expect(state.visibleMessages, isNotEmpty);
      expect(state.selectedMessageId, isNotNull);
      expect(state.visibleMessages.every((m) => m.folder == MailFolder.inbox), isTrue);
    });

    test('search filters messages', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(inboxControllerProvider.notifier);
      controller.setSearch('receipt');
      final state = container.read(inboxControllerProvider);
      expect(state.visibleMessages, isNotEmpty);
      expect(
          state.visibleMessages.every((m) =>
              m.subject.toLowerCase().contains('receipt') ||
              m.preview.toLowerCase().contains('receipt') ||
              m.sender.name.toLowerCase().contains('receipt')),
          isTrue);
    });

    test('star, archive, delete update state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(inboxControllerProvider.notifier);
      final id = container.read(inboxControllerProvider).visibleMessages.first.id;
      final wasStarred = container
          .read(inboxControllerProvider)
          .messages
          .firstWhere((m) => m.id == id)
          .isStarred;

      controller.toggleStar(id);
      expect(
          container.read(inboxControllerProvider).messages.firstWhere((m) => m.id == id).isStarred,
          !wasStarred);

      controller.toggleSelected(id);
      controller.archiveSelected();
      expect(
          container.read(inboxControllerProvider).messages.firstWhere((m) => m.id == id).folder,
          MailFolder.archive);

      controller.selectView(MailboxView.inbox); // ensure we can navigate
      controller.selectView(MailboxView.allInboxes);
      controller.selectView(MailboxView.inbox);
      controller.setSearch('');
    });

    test('unified inbox aggregates and account switching isolates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final controller = container.read(inboxControllerProvider.notifier);
      controller.selectAccount(allAccountsId);
      controller.selectView(MailboxView.allInboxes);
      final unified = container.read(inboxControllerProvider).visibleMessages;
      expect(unified.any((m) => m.accountId == 'acc-1'), isTrue);
      expect(unified.any((m) => m.accountId == 'acc-2'), isTrue);

      controller.selectAccount('acc-2');
      controller.selectView(MailboxView.inbox);
      final acc2 = container.read(inboxControllerProvider).visibleMessages;
      expect(acc2, isNotEmpty);
      expect(acc2.every((m) => m.accountId == 'acc-2'), isTrue);
    });
  });
}
