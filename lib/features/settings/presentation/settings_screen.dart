import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/app/state/settings_controller.dart';
import 'package:kmail_desktop/design_system/motion/app_motion.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/accounts/presentation/account_setup_dialog.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final colors = context.appColors.tokens;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 720),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                      child: Text('Settings',
                          style: Theme.of(context).textTheme.headlineSmall)),
                  IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: 'Close'),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _Section(
                    title: 'Appearance',
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                            label: const Text('System'),
                            selected: settings.themeMode == ThemeMode.system,
                            onSelected: (_) =>
                                controller.setThemeMode(ThemeMode.system)),
                        ChoiceChip(
                            label: const Text('Light'),
                            selected: settings.themeMode == ThemeMode.light,
                            onSelected: (_) =>
                                controller.setThemeMode(ThemeMode.light)),
                        ChoiceChip(
                            label: const Text('Dark'),
                            selected: settings.themeMode == ThemeMode.dark,
                            onSelected: (_) =>
                                controller.setThemeMode(ThemeMode.dark)),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Density',
                    subtitle:
                        'Affects list rows, padding, and spacing throughout the app.',
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                            label: const Text('Compact'),
                            selected:
                                settings.density == DensitySetting.compact,
                            onSelected: (_) =>
                                controller.setDensity(DensitySetting.compact)),
                        ChoiceChip(
                            label: const Text('Comfortable'),
                            selected:
                                settings.density == DensitySetting.comfortable,
                            onSelected: (_) => controller
                                .setDensity(DensitySetting.comfortable)),
                        ChoiceChip(
                            label: const Text('Spacious'),
                            selected:
                                settings.density == DensitySetting.spacious,
                            onSelected: (_) =>
                                controller.setDensity(DensitySetting.spacious)),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Animation',
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                            label: const Text('Full'),
                            selected:
                                settings.animation == AnimationSetting.full,
                            onSelected: (_) =>
                                controller.setAnimation(AnimationSetting.full)),
                        ChoiceChip(
                            label: const Text('Reduced'),
                            selected:
                                settings.animation == AnimationSetting.reduced,
                            onSelected: (_) => controller
                                .setAnimation(AnimationSetting.reduced)),
                        ChoiceChip(
                            label: const Text('Off'),
                            selected:
                                settings.animation == AnimationSetting.off,
                            onSelected: (_) =>
                                controller.setAnimation(AnimationSetting.off)),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Blur',
                    subtitle:
                        'Optional visual effect. The UI remains fully usable when disabled.',
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable background blur effects'),
                      value: settings.blurEnabled,
                      onChanged: controller.setBlurEnabled,
                    ),
                  ),
                  _Section(
                    title: 'Reading',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Allow remote images by default'),
                          subtitle: const Text(
                              'Blocked by default for privacy. You can still load images per message.'),
                          value: settings.remoteImages ==
                              RemoteImagesPolicy.allowed,
                          onChanged: (v) => controller.setRemoteImages(v
                              ? RemoteImagesPolicy.allowed
                              : RemoteImagesPolicy.blocked),
                        ),
                        const SizedBox(height: 8),
                        Text('Text size',
                            style: Theme.of(context).textTheme.titleSmall),
                        Slider(
                          value: settings.textScale,
                          min: 0.9,
                          max: 1.3,
                          divisions: 8,
                          label: settings.textScale.toStringAsFixed(2),
                          onChanged: controller.setTextScale,
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Accounts',
                    subtitle:
                        'Connect IMAP/SMTP email accounts. Passwords are stored in OS secure storage; account config and cached mail are stored locally.',
                    child: Consumer(builder: (context, ref, _) {
                      final inbox = ref.watch(inboxControllerProvider);
                      final controller = ref.read(inboxControllerProvider.notifier);
                      return Column(
                        children: [
                          if (inbox.accounts.isEmpty)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.mail_outline_rounded, color: colors.textSecondary),
                              title: const Text('No accounts connected'),
                              subtitle: const Text('Add an account to sync and send mail.'),
                            ),
                          for (final a in inbox.accounts)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: Color(a.colorValue),
                                child: Text(a.displayName.isNotEmpty ? a.displayName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                              ),
                              title: Text(a.displayName),
                              subtitle: Text('${a.email}${a.isDefault ? ' • Default' : ''}'),
                              trailing: Wrap(spacing: 4, children: [
                                if (!a.isDefault)
                                  TextButton(onPressed: () => controller.setDefaultAccount(a.id), child: const Text('Make default')),
                                IconButton(
                                  tooltip: 'Remove account',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text('Remove account?'),
                                        content: Text('Remove ${a.email} from this device? Cached mail for this account will be removed locally.'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Remove')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) await controller.removeAccount(a.id);
                                  },
                                  icon: const Icon(Icons.delete_outline_rounded),
                                ),
                              ]),
                            ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              onPressed: () => showDialog<void>(context: context, barrierDismissible: false, builder: (_) => const AccountSetupDialog()),
                              icon: const Icon(Icons.add),
                              label: const Text('Add account'),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  _Section(
                    title: 'Privacy & Security',
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.shield_outlined), title: Text('Remote image policy'), subtitle: Text('Remote images are blocked by default. No tracking pixels are loaded until you allow them.')),
                        ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.lock_outline_rounded), title: Text('Credentials'), subtitle: Text('Account passwords are stored using OS secure storage and are not written to plaintext logs or config.')),
                        ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.open_in_new_rounded), title: Text('External link handling'), subtitle: Text('External links require confirmation before opening in your browser.')),
                        ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.storage_outlined), title: Text('Local data'), subtitle: Text('Account config, cached messages, and drafts are stored locally on this device. Use account removal to clear account cache.')),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Kmail Desktop • Local-first email client by TheKami', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textSecondary)),                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}


