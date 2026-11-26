import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/app/state/settings_controller.dart';
import 'package:kmail_desktop/design_system/motion/app_motion.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/compose/presentation/compose_dialog.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/features/reader/presentation/reader_pane.dart';
import 'package:kmail_desktop/features/settings/presentation/settings_screen.dart';
import 'package:kmail_desktop/features/shell/presentation/widgets/mail_toolbar.dart';
import 'package:kmail_desktop/features/shell/presentation/widgets/message_list_pane.dart';
import 'package:kmail_desktop/features/shell/presentation/widgets/sidebar.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final inbox = ref.watch(inboxControllerProvider);
    final colors = context.appColors.tokens;
    final isNarrow = MediaQuery.sizeOf(context).width < 1200;
    final isCompact = MediaQuery.sizeOf(context).width < 980;

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN): const _ComposeIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF): const _SearchIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const DismissIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ComposeIntent: CallbackAction<_ComposeIntent>(onInvoke: (_) => _openCompose()),
          _SearchIntent: CallbackAction<_SearchIntent>(onInvoke: (_) {
            _searchFocus.requestFocus();
            return null;
          }),
          DismissIntent: CallbackAction<DismissIntent>(onInvoke: (_) {
            ref.read(inboxControllerProvider.notifier).clearSelection();
            return null;
          }),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: colors.background,
            body: Column(
              children: [
                MailToolbar(
                  searchFocusNode: _searchFocus,
                  onCompose: _openCompose,
                  onOpenSettings: _openSettings,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
                    child: AnimatedContainer(
                      duration: AppMotion.duration(settings.animation),
                      curve: AppMotion.curve(settings.animation),
                      decoration: BoxDecoration(
                        color: settings.blurEnabled ? colors.surface.withValues(alpha: 0.96) : colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: isCompact
                            ? _CompactLayout(onCompose: _openCompose)
                            : Row(
                                children: [
                                  SizedBox(width: isNarrow ? 240 : 260, child: const Sidebar()),
                                  VerticalDivider(width: 1, color: colors.divider),
                                  SizedBox(width: isNarrow ? 340 : 390, child: const MessageListPane()),
                                  VerticalDivider(width: 1, color: colors.divider),
                                  Expanded(child: ReaderPane(message: inbox.selectedMessage, onCompose: _openCompose)),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCompose({EmailMessage? replyTo, ComposeMode mode = ComposeMode.newMessage}) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ComposeDialog(replyTo: replyTo, mode: mode),
    );
  }

  void _openSettings() {
    showDialog<void>(
      context: context,
      builder: (_) => const SettingsScreen(),
    );
  }
}

class _ComposeIntent extends Intent {
  const _ComposeIntent();
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}

class _CompactLayout extends ConsumerWidget {
  const _CompactLayout({required this.onCompose});
  final void Function({EmailMessage? replyTo, ComposeMode mode}) onCompose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxControllerProvider);
    return Row(
      children: [
        const SizedBox(width: 220, child: Sidebar()),
        const VerticalDivider(width: 1),
        Expanded(
          child: inbox.selectedMessage == null
              ? const MessageListPane()
              : ReaderPane(message: inbox.selectedMessage, onCompose: onCompose),
        ),
      ],
    );
  }
}
