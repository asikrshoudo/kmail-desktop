import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_radii.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/accounts/presentation/account_setup_dialog.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_state.dart';
import 'package:kmail_desktop/shared/models/folder_item.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxControllerProvider);
    final colors = context.appColors.tokens;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: colors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      Icon(Icons.mail_outline_rounded, color: colors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Kmail',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        inbox.isUnified
                            ? 'All accounts'
                            : (inbox.activeAccount?.email ??
                                'No account connected'),
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _AccountSwitcher(inbox: inbox),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: [
                for (final folder in inbox.folders)
                  _SidebarItem(
                    item: folder,
                    selected: inbox.selectedView == folder.view,
                    onTap: () => ref
                        .read(inboxControllerProvider.notifier)
                        .selectView(folder.view),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const AccountSetupDialog(),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add account'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSwitcher extends ConsumerWidget {
  const _AccountSwitcher({required this.inbox});
  final InboxState inbox;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors.tokens;
    final active = inbox.activeAccount;
    final label =
        inbox.isUnified ? 'All Inboxes' : (active?.displayName ?? 'No account');
    final email = inbox.isUnified
        ? (inbox.hasAccounts
            ? 'Unified view across accounts'
            : 'Add an account to get started')
        : (active?.email ?? 'Connect an email account');
    final color = inbox.isUnified
        ? colors.primary
        : Color(active?.colorValue ?? 0xFF1F4B99);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.lg),
      onTap: () => _showAccountSheet(context, ref),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color,
              child: Icon(
                  inbox.isUnified
                      ? Icons.all_inbox_rounded
                      : Icons.person_rounded,
                  size: 16,
                  color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: Theme.of(context).textTheme.labelLarge,
                      overflow: TextOverflow.ellipsis),
                  Text(email,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Icon(Icons.unfold_more_rounded,
                color: colors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }

  void _showAccountSheet(BuildContext context, WidgetRef ref) {
    final inbox = ref.read(inboxControllerProvider);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accounts',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md)),
                  leading:
                      const CircleAvatar(child: Icon(Icons.all_inbox_rounded)),
                  title: const Text('All Inboxes'),
                  subtitle:
                      const Text('Unified inbox across connected accounts'),
                  trailing:
                      inbox.isUnified ? const Icon(Icons.check_rounded) : null,
                  onTap: () {
                    ref
                        .read(inboxControllerProvider.notifier)
                        .selectAccount(allAccountsId);
                    Navigator.pop(context);
                  },
                ),
                for (final a in inbox.accounts)
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.md)),
                    leading: CircleAvatar(
                      backgroundColor: Color(a.colorValue),
                      child: Text(
                          a.displayName.isNotEmpty
                              ? a.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text(a.displayName),
                    subtitle: Text(a.email),
                    trailing: inbox.selectedAccountId == a.id
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () {
                      ref
                          .read(inboxControllerProvider.notifier)
                          .selectAccount(a.id);
                      Navigator.pop(context);
                    },
                  ),
                const Divider(),
                ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md)),
                  leading: const Icon(Icons.add_rounded),
                  title: const Text('Add account'),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const AccountSetupDialog());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem(
      {required this.item, required this.selected, required this.onTap});
  final FolderItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors.tokens;
    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? colors.selection : Colors.transparent,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(item.icon,
                    size: 20,
                    color: selected ? colors.primary : colors.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected
                              ? colors.textPrimary
                              : colors.textPrimary,
                        ),
                  ),
                ),
                if (item.count > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.primary.withValues(alpha: 0.12)
                          : colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                      border: Border.all(
                          color: selected
                              ? colors.primary.withValues(alpha: 0.18)
                              : colors.border),
                    ),
                    child: Text('${item.count}',
                        style: Theme.of(context).textTheme.labelSmall),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
