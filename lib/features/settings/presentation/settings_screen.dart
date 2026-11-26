import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/app/state/settings_controller.dart';
import 'package:kmail_desktop/design_system/motion/app_motion.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final colors = context.appColors.tokens;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 920,
        height: 720,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(child: Text('Settings', style: Theme.of(context).textTheme.headlineSmall)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded), tooltip: 'Close'),
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
                        ChoiceChip(label: const Text('System'), selected: settings.themeMode == ThemeMode.system, onSelected: (_) => controller.setThemeMode(ThemeMode.system)),
                        ChoiceChip(label: const Text('Light'), selected: settings.themeMode == ThemeMode.light, onSelected: (_) => controller.setThemeMode(ThemeMode.light)),
                        ChoiceChip(label: const Text('Dark'), selected: settings.themeMode == ThemeMode.dark, onSelected: (_) => controller.setThemeMode(ThemeMode.dark)),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Density',
                    subtitle: 'Affects list rows, padding, and spacing throughout the app.',
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(label: const Text('Compact'), selected: settings.density == DensitySetting.compact, onSelected: (_) => controller.setDensity(DensitySetting.compact)),
                        ChoiceChip(label: const Text('Comfortable'), selected: settings.density == DensitySetting.comfortable, onSelected: (_) => controller.setDensity(DensitySetting.comfortable)),
                        ChoiceChip(label: const Text('Spacious'), selected: settings.density == DensitySetting.spacious, onSelected: (_) => controller.setDensity(DensitySetting.spacious)),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Animation',
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(label: const Text('Full'), selected: settings.animation == AnimationSetting.full, onSelected: (_) => controller.setAnimation(AnimationSetting.full)),
                        ChoiceChip(label: const Text('Reduced'), selected: settings.animation == AnimationSetting.reduced, onSelected: (_) => controller.setAnimation(AnimationSetting.reduced)),
                        ChoiceChip(label: const Text('Off'), selected: settings.animation == AnimationSetting.off, onSelected: (_) => controller.setAnimation(AnimationSetting.off)),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Blur',
                    subtitle: 'Optional visual effect. The UI remains fully usable when disabled.',
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
                          subtitle: const Text('Blocked by default for privacy. You can still load images per message.'),
                          value: settings.remoteImages == RemoteImagesPolicy.allowed,
                          onChanged: (v) => controller.setRemoteImages(v ? RemoteImagesPolicy.allowed : RemoteImagesPolicy.blocked),
                        ),
                        const SizedBox(height: 8),
                        Text('Text size', style: Theme.of(context).textTheme.titleSmall),
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
                    title: 'Notifications',
                    subtitle: 'UI foundation only. Desktop notifications are planned for a future phase.',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.notifications_outlined, color: colors.textSecondary),
                      title: const Text('Notification preferences'),
                      subtitle: const Text('Planned: new mail alerts, quiet hours, account filters.'),
                    ),
                  ),
                  _Section(
                    title: 'Accounts',
                    subtitle: 'UI foundation only. Real account management and auth are planned.',
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(backgroundColor: Color(0xFF1F4B99), child: const Text('A', style: TextStyle(color: Colors.white))),
                          title: const Text('Alex Morgan'),
                          subtitle: const Text('alex.morgan@kmail.app • Default (mock)'),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add account (planned)')),
                        ),
                      ],
                    ),
                  ),
                  _Section(
                    title: 'Privacy',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.shield_outlined), title: Text('Remote image policy'), subtitle: Text('Remote images are blocked by default. No tracking pixels are loaded until you allow them.')),
                        ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.open_in_new_rounded), title: Text('External link handling'), subtitle: Text('External links require confirmation before opening in your browser.')),
                        ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.storage_outlined), title: Text('Local data'), subtitle: Text('Phase 1 uses in-memory mock data only. Local database and encrypted storage are planned.')),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Kmail Desktop Phase 1 foundation • Mock data only', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.textSecondary)),
                ],
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
