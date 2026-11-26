import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

enum ComposeMode { newMessage, reply, replyAll, forward }

class ComposeDialog extends ConsumerStatefulWidget {
  const ComposeDialog({
    super.key,
    this.replyTo,
    this.mode = ComposeMode.newMessage,
  });

  final EmailMessage? replyTo;
  final ComposeMode mode;

  @override
  ConsumerState<ComposeDialog> createState() => _ComposeDialogState();
}

class _ComposeDialogState extends ConsumerState<ComposeDialog> {
  late final TextEditingController _to;
  late final TextEditingController _cc;
  late final TextEditingController _bcc;
  late final TextEditingController _subject;
  late final TextEditingController _body;
  bool _showCcBcc = false;

  @override
  void initState() {
    super.initState();
    final reply = widget.replyTo;
    final subject = switch (widget.mode) {
      ComposeMode.reply || ComposeMode.replyAll =>
        reply != null ? 'Re: ${reply.subject}' : '',
      ComposeMode.forward => reply != null ? 'Fwd: ${reply.subject}' : '',
      ComposeMode.newMessage => '',
    };
    final to = switch (widget.mode) {
      ComposeMode.reply || ComposeMode.replyAll => reply?.sender.email ?? '',
      _ => '',
    };
    final cc = widget.mode == ComposeMode.replyAll
        ? reply?.cc.map((e) => e.email).join(', ') ?? ''
        : '';
    final body = reply == null
        ? ''
        : '\n\n\nOn ${reply.date}, ${reply.sender.display} wrote:\n> ${reply.bodyPlainText.replaceAll('\n', '\n> ')}';
    _to = TextEditingController(text: to);
    _cc = TextEditingController(text: cc);
    _bcc = TextEditingController();
    _subject = TextEditingController(text: subject);
    _body = TextEditingController(text: body);
    _showCcBcc = cc.isNotEmpty;
  }

  @override
  void dispose() {
    _to.dispose();
    _cc.dispose();
    _bcc.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors.tokens;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 860,
        height: 680,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _title(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: _confirmClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _field('To', _to),
                    if (_showCcBcc) ...[
                      const SizedBox(height: 8),
                      _field('Cc', _cc),
                      const SizedBox(height: 8),
                      _field('Bcc', _bcc),
                    ] else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(() => _showCcBcc = true),
                          child: const Text('Add Cc/Bcc'),
                        ),
                      ),
                    const SizedBox(height: 8),
                    _field('Subject', _subject),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.border),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Formatting UI foundation (mock)',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: _body,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: 'Write your message...',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save draft'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _discard,
                    child: const Text('Discard'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title() => switch (widget.mode) {
        ComposeMode.newMessage => 'New message',
        ComposeMode.reply => 'Reply',
        ComposeMode.replyAll => 'Reply all',
        ComposeMode.forward => 'Forward',
      };

  Widget _field(String label, TextEditingController controller) => TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
      );

  EmailMessage _buildMessage({required MailFolder folder, required bool draft}) {
    final now = DateTime.now();
    final state = ref.read(inboxControllerProvider);
    final account = state.activeAccount ?? state.accounts.first;
    EmailAddress parse(String raw) {
      final value = raw.trim();
      if (value.isEmpty) return const EmailAddress(name: '', email: '');
      return EmailAddress(name: value.split('@').first, email: value);
    }

    List<EmailAddress> parseList(String raw) => raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map(parse)
        .toList();
    final body = _body.text;
    return EmailMessage(
      id: widget.replyTo != null && draft
          ? 'draft-${widget.replyTo!.id}-${widget.mode.name}'
          : 'local-${now.microsecondsSinceEpoch}',
      accountId: account.id,
      folder: folder,
      sender: EmailAddress(name: account.name, email: account.email),
      to: parseList(_to.text),
      cc: parseList(_cc.text),
      bcc: parseList(_bcc.text),
      subject:
          _subject.text.trim().isEmpty ? '(No subject)' : _subject.text.trim(),
      preview: body.trim().replaceAll('\n', ' ').take(120),
      bodyPlainText: body,
      bodyHtml:
          '<div style="font-family:Segoe UI,Arial,sans-serif;line-height:1.6">${_escape(body)}</div>',
      date: now,
      isDraft: draft,
      isUnread: false,
    );
  }

  void _saveDraft() {
    ref.read(inboxControllerProvider.notifier).saveDraft(
          _buildMessage(folder: MailFolder.drafts, draft: true),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Draft saved (mock local state).')),
    );
  }

  void _discard() => Navigator.of(context).pop();

  void _send() {
    if (_to.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one recipient.')),
      );
      return;
    }
    ref.read(inboxControllerProvider.notifier).sendMock(
          _buildMessage(folder: MailFolder.sent, draft: false),
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message sent (simulated). No network call was made.'),
      ),
    );
  }

  Future<void> _confirmClose() async {
    if (_to.text.isEmpty && _subject.text.isEmpty && _body.text.trim().isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final shouldClose = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard unsaved changes?'),
        content: const Text('You have unsaved compose content.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (shouldClose == true && mounted) Navigator.of(context).pop();
  }

  String _escape(String text) => text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;')
      .replaceAll('\n', '<br/>');
}

extension on String {
  String take(int max) => length <= max ? this : substring(0, max);
}
