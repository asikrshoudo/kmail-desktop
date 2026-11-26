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
      expect(state.visibleMessages.every((m) => m.folder == MailFolder.inbox),
          isTrue);
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
      final id =
          container.read(inboxControllerProvider).visibleMessages.first.id;

      controller.toggleStar(id);
      expect(
          container
              .read(inboxControllerProvider)
              .messages
              .firstWhere((m) => m.id == id)
              .isStarred,
          isTrue);

      controller.toggleSelected(id);
      controller.archiveSelected();
      expect(
          container
              .read(inboxControllerProvider)
              .messages
              .firstWhere((m) => m.id == id)
              .folder,
          MailFolder.archive);

      controller.selectFolder(MailFolder.archive);
      final archivedId =
          container.read(inboxControllerProvider).visibleMessages.first.id;
      controller.toggleSelected(archivedId);
      controller.deleteSelected();
      expect(
          container
              .read(inboxControllerProvider)
              .messages
              .firstWhere((m) => m.id == archivedId)
              .folder,
          MailFolder.trash);
    });
  });
}
