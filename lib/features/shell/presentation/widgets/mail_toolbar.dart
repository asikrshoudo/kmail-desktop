import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';

class MailToolbar extends ConsumerWidget {
  const MailToolbar({
    super.key,
    required this.searchFocusNode,
    required this.onCompose,
    required this.onOpenSettings,
  });

  final FocusNode searchFocusNode;
  final VoidCallback onCompose;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxControllerProvider);
    final colors = context.appColors.tokens;
    final hasSelection = inbox.selectedIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      color: colors.background,
      child: Row(
        children: [
          FilledButton.icon(
              onPressed: onCompose,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Compose')),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
              tooltip: 'Refresh (mock)',
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mock refresh complete.'))),
              icon: const Icon(Icons.refresh_rounded)),
          IconButton(
              tooltip: 'Select all visible',
              onPressed:
                  ref.read(inboxControllerProvider.notifier).selectAllVisible,
              icon: const Icon(Icons.select_all_rounded)),
          IconButton(
              tooltip: 'Mark read',
              onPressed: hasSelection
                  ? () => ref
                      .read(inboxControllerProvider.notifier)
                      .markSelectedRead(true)
                  : null,
              icon: const Icon(Icons.mark_email_read_outlined)),
          IconButton(
              tooltip: 'Mark unread',
              onPressed: hasSelection
                  ? () => ref
                      .read(inboxControllerProvider.notifier)
                      .markSelectedRead(false)
                  : null,
              icon: const Icon(Icons.mark_email_unread_outlined)),
          IconButton(
              tooltip: 'Archive',
              onPressed: hasSelection
                  ? ref.read(inboxControllerProvider.notifier).archiveSelected
                  : null,
              icon: const Icon(Icons.archive_outlined)),
          IconButton(
              tooltip: 'Delete',
              onPressed: hasSelection
                  ? ref.read(inboxControllerProvider.notifier).deleteSelected
                  : null,
              icon: const Icon(Icons.delete_outline_rounded)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: TextField(
                focusNode: searchFocusNode,
                onChanged: ref.read(inboxControllerProvider.notifier).setSearch,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Search mail, senders, or subjects',
                  suffixIcon: inbox.searchQuery.isNotEmpty
                      ? IconButton(
                          tooltip: 'Clear search',
                          onPressed: () => ref
                              .read(inboxControllerProvider.notifier)
                              .setSearch(''),
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          PopupMenuButton<String>(
            tooltip: 'Filter and sort',
            icon: const Icon(Icons.tune_rounded),
            onSelected: (value) {
              final c = ref.read(inboxControllerProvider.notifier);
              switch (value) {
                case 'unread':
                  c.toggleUnreadOnly();
                  break;
                case 'attachments':
                  c.toggleAttachmentsOnly();
                  break;
                case 'newest':
                  c.setSortNewestFirst(true);
                  break;
                case 'oldest':
                  c.setSortNewestFirst(false);
                  break;
              }
            },
            itemBuilder: (context) => [
              CheckedPopupMenuItem(
                  value: 'unread',
                  checked: inbox.filterUnreadOnly,
                  child: const Text('Unread only')),
              CheckedPopupMenuItem(
                  value: 'attachments',
                  checked: inbox.filterAttachmentsOnly,
                  child: const Text('Has attachments')),
              const PopupMenuDivider(),
              CheckedPopupMenuItem(
                  value: 'newest',
                  checked: inbox.sortNewestFirst,
                  child: const Text('Newest first')),
              CheckedPopupMenuItem(
                  value: 'oldest',
                  checked: !inbox.sortNewestFirst,
                  child: const Text('Oldest first')),
            ],
          ),
          IconButton(
              tooltip: 'Settings',
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined)),
        ],
      ),
    );
  }
}
