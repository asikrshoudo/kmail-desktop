import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kmail_desktop/app/state/settings_controller.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_radii.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_state.dart';
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
                    Text(_viewTitle(inbox.selectedView), style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      '${messages.length} messages • ${inbox.isUnified ? 'All accounts' : (inbox.activeAccount?.email ?? 'No account')}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (inbox.selectedIds.isNotEmpty)
                Text('${inbox.selectedIds.length} selected', style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
        if (inbox.isSyncing)
          const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: _buildBody(context, inbox, messages, density),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, InboxState inbox, List<EmailMessage> messages, double density) {
    if (inbox.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!inbox.hasAccounts) {
      return const _StateView(
        icon: Icons.mail_outline_rounded,
        title: 'No accounts connected',
        subtitle: 'Add an email account to start syncing your inbox.',
      );
    }
    if (inbox.error != null && messages.isEmpty) {
      return _StateView(
        icon: Icons.cloud_off_rounded,
        title: 'Unable to load mail',
        subtitle: inbox.error!,
      );
    }
    if (messages.isEmpty) {
      return _StateView(
        icon: inbox.searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.inbox_outlined,
        title: inbox.searchQuery.isNotEmpty ? 'No messages match your search' : 'No messages in this view',
        subtitle: inbox.searchQuery.isNotEmpty
            ? 'Try a different keyword or clear filters.'
            : 'New messages will appear here after sync.',
      );
    }
    return ListView.separated(
      itemCount: messages.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: context.appColors.tokens.divider),
      itemBuilder: (context, index) {
        final message = messages[index];
        return _MessageRow(
          message: message,
          selected: inbox.selectedMessageId == message.id,
          checked: inbox.selectedIds.contains(message.id),
          density: density,
          showAccount: inbox.isUnified,
          accountLabel: _accountLabel(inbox, message.accountId),
        );
      },
    );
  }

  String _accountLabel(InboxState inbox, String accountId) {
    for (final a in inbox.accounts) {
      if (a.id == accountId) return a.email;
    }
    return accountId;
  }

  String _viewTitle(MailboxView view) => switch (view) {
    MailboxView.allInboxes => 'All Inboxes',
    MailboxView.starred => 'Starred',
    MailboxView.unread => 'Unread',
    MailboxView.inbox => 'Inbox',
    MailboxView.drafts => 'Drafts',
    MailboxView.sent => 'Sent',
    MailboxView.spam => 'Spam',
    MailboxView.trash => 'Trash',
  };
}

class _MessageRow extends ConsumerWidget {
  const _MessageRow({required this.message, required this.selected, required this.checked, required this.density, required this.showAccount, required this.accountLabel});
  final EmailMessage message;
  final bool selected;
  final bool checked;
  final double density;
  final bool showAccount;
  final String accountLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors.tokens;
    final controller = ref.read(inboxControllerProvider.notifier);
    final date = DateFormat('MMM d').format(message.date);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.sm));

    return Material(
      color: selected ? colors.selection : Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectMessage(message.id),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 10 * density),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: checked, onChanged: (_) => controller.toggleSelected(message.id), shape: shape),
              CircleAvatar(
                radius: 17,
                backgroundColor: colors.surfaceMuted,
                child: Text(
                  message.sender.name.isNotEmpty ? message.sender.name[0].toUpperCase() : '?',
                  style: TextStyle(color: colors.textPrimary),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(child: Text(message.sender.name.isNotEmpty ? message.sender.name : message.sender.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: message.isUnread ? FontWeight.w700 : FontWeight.w600))),
                      Text(date, style: Theme.of(context).textTheme.bodySmall),
                    ]),
                    const SizedBox(height: 2),
                    Row(children: [
                      Expanded(child: Text(message.subject, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: message.isUnread ? FontWeight.w600 : FontWeight.w400))),
                      if (message.hasAttachments) Icon(Icons.attach_file_rounded, size: 16, color: colors.textSecondary),
                      IconButton(
                        tooltip: message.isStarred ? 'Unstar' : 'Star',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => controller.toggleStar(message.id),
                        icon: Icon(message.isStarred ? Icons.star_rounded : Icons.star_border_rounded, size: 18, color: message.isStarred ? colors.warning : colors.textSecondary),
                      ),
                    ]),
                    Text(message.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                    if (showAccount)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(accountLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.textSecondary)),
                      ),
                  ],
                ),
              ),
              if (message.isUnread)
                Container(margin: const EdgeInsets.only(left: 6, top: 8), width: 8, height: 8, decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: colors.textSecondary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
