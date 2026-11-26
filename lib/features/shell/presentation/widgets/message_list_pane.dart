import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kmail_desktop/app/state/settings_controller.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class MessageListPane extends ConsumerWidget {
  const MessageListPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final messages = inbox.visibleMessages;
    final colors = context.appColors.tokens;
    final density = settings.densityScale;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12 * density),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.divider))),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_folderTitle(inbox.selectedFolder), style: Theme.of(context).textTheme.titleMedium),
                    Text('${messages.length} messages • Mock data', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (inbox.selectedIds.isNotEmpty)
                Text('${inbox.selectedIds.length} selected', style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
        Expanded(
          child: messages.isEmpty
              ? _EmptyList(searching: inbox.searchQuery.isNotEmpty)
              : ListView.separated(
                  itemCount: messages.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: colors.divider),
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageRow(
                      message: message,
                      selected: inbox.selectedMessageId == message.id,
                      checked: inbox.selectedIds.contains(message.id),
                      density: density,
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _folderTitle(MailFolder folder) {
    switch (folder) {
      case MailFolder.inbox:
        return 'Inbox';
      case MailFolder.starred:
        return 'Starred';
      case MailFolder.snoozed:
        return 'Snoozed';
      case MailFolder.drafts:
        return 'Drafts';
      case MailFolder.sent:
        return 'Sent';
      case MailFolder.archive:
        return 'Archive';
      case MailFolder.spam:
        return 'Spam';
      case MailFolder.trash:
        return 'Trash';
      case MailFolder.custom:
        return 'Folder';
    }
  }
}

class _MessageRow extends ConsumerWidget {
  const _MessageRow({required this.message, required this.selected, required this.checked, required this.density});
  final EmailMessage message;
  final bool selected;
  final bool checked;
  final double density;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors.tokens;
    final controller = ref.read(inboxControllerProvider.notifier);
    final bg = selected ? colors.selection : Colors.transparent;
    final date = DateFormat('MMM d').format(message.date);

    return InkWell(
      onTap: () => controller.selectMessage(message.id),
      child: Container(
        color: bg,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10 * density),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: checked, onChanged: (_) => controller.toggleSelected(message.id)),
            CircleAvatar(
              radius: 17,
              backgroundColor: colors.surfaceMuted,
              child: Text(message.sender.name.isNotEmpty ? message.sender.name[0] : '?', style: TextStyle(color: colors.textPrimary)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.sender.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: message.isUnread ? FontWeight.w700 : FontWeight.w600,
                              ),
                        ),
                      ),
                      Text(date, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.subject,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: message.isUnread ? FontWeight.w600 : FontWeight.w400,
                              ),
                        ),
                      ),
                      if (message.hasAttachments) Icon(Icons.attach_file_rounded, size: 16, color: colors.textSecondary),
                      IconButton(
                        tooltip: message.isStarred ? 'Unstar' : 'Star',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => controller.toggleStar(message.id),
                        icon: Icon(message.isStarred ? Icons.star_rounded : Icons.star_border_rounded, size: 18, color: message.isStarred ? colors.warning : colors.textSecondary),
                      ),
                    ],
                  ),
                  Text(
                    message.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (message.isUnread)
              Container(
                margin: const EdgeInsets.only(left: 6, top: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.searching});
  final bool searching;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(searching ? Icons.search_off_rounded : Icons.inbox_outlined, size: 42, color: colors.textSecondary),
            const SizedBox(height: 12),
            Text(searching ? 'No messages match your search' : 'No messages in this folder', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              searching ? 'Try a different keyword or clear filters.' : 'Messages you receive or move will appear here.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
