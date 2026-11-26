import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kmail_desktop/app/state/settings_controller.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/attachments/presentation/attachment_list.dart';
import 'package:kmail_desktop/features/compose/presentation/compose_dialog.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/features/reader/html/html_sanitizer.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';
import 'package:url_launcher/url_launcher.dart';

class ReaderPane extends ConsumerStatefulWidget {
  const ReaderPane({super.key, required this.message, required this.onCompose});
  final EmailMessage? message;
  final void Function({EmailMessage? replyTo, ComposeMode mode}) onCompose;

  @override
  ConsumerState<ReaderPane> createState() => _ReaderPaneState();
}

class _ReaderPaneState extends ConsumerState<ReaderPane> {
  bool _allowRemoteForThisMessage = false;
  String? _lastMessageId;

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final colors = context.appColors.tokens;
    if (message == null) {
      return Center(
        child: Text('Select a message to read',
            style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    if (_lastMessageId != message.id) {
      _lastMessageId = message.id;
      _allowRemoteForThisMessage = false;
    }

    final settings = ref.watch(settingsControllerProvider);
    final allowRemote = settings.remoteImages == RemoteImagesPolicy.allowed ||
        _allowRemoteForThisMessage;
    final sanitized = HtmlSanitizer.sanitize(message.bodyHtml,
        allowRemoteImages: allowRemote);
    final date = DateFormat('EEE, MMM d, y • h:mm a').format(message.date);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.divider))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                      child: Text(message.subject,
                          style: Theme.of(context).textTheme.headlineSmall)),
                  IconButton(
                    tooltip: message.isStarred ? 'Unstar' : 'Star',
                    onPressed: () => ref
                        .read(inboxControllerProvider.notifier)
                        .toggleStar(message.id),
                    icon: Icon(
                        message.isStarred
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: message.isStarred ? colors.warning : null),
                  ),
                  IconButton(
                      tooltip: 'Archive',
                      onPressed: () => ref
                          .read(inboxControllerProvider.notifier)
                          .archiveMessage(message.id),
                      icon: const Icon(Icons.archive_outlined)),
                  IconButton(
                      tooltip: 'Delete',
                      onPressed: () => ref
                          .read(inboxControllerProvider.notifier)
                          .deleteMessage(message.id),
                      icon: const Icon(Icons.delete_outline_rounded)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                      radius: 18,
                      backgroundColor: colors.surfaceMuted,
                      child: Text(message.sender.name.isNotEmpty
                          ? message.sender.name[0]
                          : '?')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(message.sender.display,
                            style: Theme.of(context).textTheme.titleSmall),
                        Text(
                            'To: ${message.to.map((e) => e.display).join(', ')}',
                            style: Theme.of(context).textTheme.bodySmall),
                        if (message.cc.isNotEmpty)
                          Text(
                              'Cc: ${message.cc.map((e) => e.display).join(', ')}',
                              style: Theme.of(context).textTheme.bodySmall),
                        Text(date,
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                      onPressed: () => widget.onCompose(
                          replyTo: message, mode: ComposeMode.reply),
                      icon: const Icon(Icons.reply_rounded, size: 18),
                      label: const Text('Reply')),
                  OutlinedButton.icon(
                      onPressed: () => widget.onCompose(
                          replyTo: message, mode: ComposeMode.replyAll),
                      icon: const Icon(Icons.reply_all_rounded, size: 18),
                      label: const Text('Reply all')),
                  OutlinedButton.icon(
                      onPressed: () => widget.onCompose(
                          replyTo: message, mode: ComposeMode.forward),
                      icon: const Icon(Icons.forward_rounded, size: 18),
                      label: const Text('Forward')),
                ],
              ),
            ],
          ),
        ),
        if (sanitized.hasRemoteImages && !allowRemote)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            color: colors.surfaceMuted,
            child: Row(
              children: [
                Icon(Icons.image_not_supported_outlined,
                    size: 18, color: colors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text('Remote images are blocked for privacy.',
                        style: Theme.of(context).textTheme.bodySmall)),
                TextButton(
                    onPressed: () =>
                        setState(() => _allowRemoteForThisMessage = true),
                    child: const Text('Load images')),
              ],
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (message.labels.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Wrap(spacing: 8, children: [
                    for (final l in message.labels) Chip(label: Text(l))
                  ]),
                ),
              SelectionArea(
                child: Html(
                  data: sanitized.html,
                  style: {
                    'body': Style(
                        margin: Margins.zero,
                        padding: HtmlPaddings.zero,
                        fontSize: FontSize(14),
                        lineHeight: const LineHeight(1.6)),
                    'table': Style(border: Border.all(color: colors.border)),
                    'td': Style(
                        padding: HtmlPaddings.all(6),
                        border: Border.all(color: colors.border)),
                    'th': Style(
                        padding: HtmlPaddings.all(6),
                        border: Border.all(color: colors.border)),
                    'blockquote': Style(
                        margin: Margins.symmetric(vertical: 8),
                        padding: HtmlPaddings.only(left: 12),
                        border: Border(
                            left: BorderSide(color: colors.border, width: 3)),
                        color: colors.textSecondary),
                    'a': Style(color: colors.primary),
                  },
                  onLinkTap: (url, _, __) => _handleLink(context, url),
                ),
              ),
              if (message.attachments.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Divider(color: colors.divider),
                const SizedBox(height: AppSpacing.sm),
                Text('Attachments',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                AttachmentList(attachments: message.attachments),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleLink(BuildContext context, String? url) async {
    if (url == null || url.trim().isEmpty) return;
    if (HtmlSanitizer.hasUnsafeUrl(url)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Blocked unsafe link.')));
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !(uri.isScheme('http') ||
            uri.isScheme('https') ||
            uri.isScheme('mailto'))) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported link type.')));
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open external link?'),
        content: Text(url),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open')),
        ],
      ),
    );
    if (confirm == true) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
