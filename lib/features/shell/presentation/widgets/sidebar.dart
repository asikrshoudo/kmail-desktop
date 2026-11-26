import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_radii.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/shared/models/folder_item.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxControllerProvider);
    final colors = context.appColors.tokens;
    final account = inbox.account;

    return Container(
      color: colors.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                      Text('Demo workspace',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(account.colorValue),
                    child: Text(account.name.substring(0, 1),
                        style: const TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(account.name,
                            style: Theme.of(context).textTheme.labelLarge,
                            overflow: TextOverflow.ellipsis),
                        Text(account.email,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: [
                for (final folder in inbox.folders)
                  _SidebarItem(
                    item: folder,
                    selected: inbox.selectedFolder == folder.folder ||
                        (folder.folder == MailFolder.starred &&
                            inbox.selectedFolder == MailFolder.starred),
                    onTap: () => ref
                        .read(inboxControllerProvider.notifier)
                        .selectFolder(folder.folder),
                  ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: Text('LABELS',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                ),
                _LabelRow(label: 'Work', color: colors.info),
                _LabelRow(label: 'Personal', color: colors.accent),
                _LabelRow(label: 'Receipts', color: colors.warning),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Add account is planned for a future phase.')));
              },
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add account'),
            ),
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        dense: true,
        selected: selected,
        leading: Icon(item.icon,
            size: 20, color: selected ? colors.primary : colors.textSecondary),
        title: Text(item.label),
        trailing: item.count > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${item.count}',
                    style: Theme.of(context).textTheme.labelSmall),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
