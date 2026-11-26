import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_radii.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/accounts/data/mail_account_config.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';
import 'package:uuid/uuid.dart';

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
  bool _sending = false;
  String? _selectedAccountId;
  final List<Attachment> _attachments = [];
  final _uuid = const Uuid();

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
    final inbox = ref.read(inboxControllerProvider);
    _selectedAccountId = reply?.accountId ?? inbox.activeAccount?.id;
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
    final inbox = ref.watch(inboxControllerProvider);
    final accounts = inbox.accounts;
    _selectedAccountId ??= inbox.activeAccount?.id;

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
                  Expanded(child: Text(_title(), style: Theme.of(context).textTheme.titleLarge)),
                  IconButton(tooltip: 'Close', onPressed: _confirmClose, icon: const Icon(Icons.close_rounded)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    if (accounts.isNotEmpty)
                      DropdownButtonFormField<String>(
                        value: accounts.any((a) => a.id == _selectedAccountId) ? _selectedAccountId : accounts.first.id,
                        decoration: const InputDecoration(labelText: 'From'),
                        items: [
                          for (final a in accounts)
                            DropdownMenuItem(value: a.id, child: Text('${a.displayName} <${a.email}>', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: _sending ? null : (v) => setState(() => _selectedAccountId = v),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(color: colors.warning.withValues(alpha: 0.25)),
                        ),
                        child: Text('No account configured. Add an account before sending.', style: TextStyle(color: colors.warning)),
                      ),
                    const SizedBox(height: 8),
                    _field('To', _to),
                    if (_showCcBcc) ...[
                      const SizedBox(height: 8),
                      _field('Cc', _cc),
                      const SizedBox(height: 8),
                      _field('Bcc', _bcc),
                    ] else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(onPressed: () => setState(() => _showCcBcc = true), child: const Text('Add Cc/Bcc')),
                      ),
                    const SizedBox(height: 8),
                    _field('Subject', _subject),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _sending ? null : _pickAttachments,
                          icon: const Icon(Icons.attach_file_rounded, size: 18),
                          label: const Text('Attach files'),
                        ),
                        const SizedBox(width: 8),
                        Text('Plain text/HTML supported on send', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _attachments.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final a = _attachments[i];
                            return InputChip(
                              label: Text(a.name, overflow: TextOverflow.ellipsis),
                              onDeleted: _sending ? null : () => setState(() => _attachments.removeAt(i)),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Expanded(
                      child: TextField(
                        controller: _body,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(hintText: 'Write your message...'),
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
                    onPressed: _sending ? null : _saveDraft,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save draft'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(onPressed: _sending ? null : _discard, child: const Text('Discard')),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _sending || accounts.isEmpty ? null : _send,
                    icon: _sending
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_sending ? 'Sending...' : 'Send'),
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
    final MailAccountConfig? account = state.accounts
        .where((a) => a.id == _selectedAccountId)
        .cast<MailAccountConfig?>()
        .firstWhere((a) => a != null, orElse: () => state.activeAccount);
    final from = account ?? (state.accounts.isNotEmpty ? state.accounts.first : null);
    EmailAddress parse(String raw) {
      final value = raw.trim();
      if (value.isEmpty) return const EmailAddress(name: '', email: '');
      return EmailAddress(name: value.contains('@') ? value.split('@').first : value, email: value);
    }

    List<EmailAddress> parseList(String raw) => raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).map(parse).toList();
    final body = _body.text;
    final id = widget.replyTo != null && draft
        ? 'local-draft-${widget.replyTo!.id}-${widget.mode.name}'
        : 'local-${_uuid.v4()}';
    return EmailMessage(
      id: id,
      accountId: from?.id ?? '',
      folder: folder,
      sender: EmailAddress(name: from?.displayName ?? 'Kmail', email: from?.email ?? ''),
      to: parseList(_to.text),
      cc: parseList(_cc.text),
      bcc: parseList(_bcc.text),
      subject: _subject.text.trim().isEmpty ? '(No subject)' : _subject.text.trim(),
      preview: body.trim().replaceAll(RegExp(r'\s+'), ' ').take(140),
      bodyPlainText: body,
      bodyHtml: '<div style="font-family:Segoe UI,Arial,sans-serif;line-height:1.6">${_escape(body)}</div>',
      date: now,
      isDraft: draft,
      isUnread: false,
      attachments: List<Attachment>.from(_attachments),
    );
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, withData: false);
    if (result == null) return;
    setState(() {
      for (final f in result.files) {
        _attachments.add(Attachment(
          id: 'att-${_uuid.v4()}',
          name: f.name,
          type: _typeForName(f.name),
          sizeBytes: f.size,
          localPath: f.path,
        ));
      }
    });
  }

  AttachmentType _typeForName(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'pdf' => AttachmentType.pdf, 'png' => AttachmentType.png, 'jpg' || 'jpeg' => AttachmentType.jpg,
      'gif' => AttachmentType.gif, 'webp' => AttachmentType.webp, 'txt' || 'md' || 'log' => AttachmentType.txt,
      'csv' => AttachmentType.csv, 'doc' || 'docx' => AttachmentType.docx, 'xls' || 'xlsx' => AttachmentType.xlsx,
      'zip' || 'rar' || '7z' => AttachmentType.zip, 'html' || 'htm' => AttachmentType.html, _ => AttachmentType.unknown,
    };
  }

  List<String> _parseEmails(String raw, {bool collectInvalid = false}) {
    final parts = raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final valid = <String>[]; final invalid = <String>[];
    for (final p in parts) { (re.hasMatch(p) ? valid : invalid).add(p); }
    return collectInvalid ? invalid : valid;
  }

  Future<void> _saveDraft() async {
    await ref.read(inboxControllerProvider.notifier).saveDraft(_buildMessage(folder: MailFolder.drafts, draft: true));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved locally.')));
  }

  void _discard() async {
    if (_to.text.isEmpty && _subject.text.isEmpty && _body.text.trim().isEmpty && _attachments.isEmpty) { Navigator.of(context).pop(); return; }
    final confirm = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Discard draft?'), content: const Text('This will discard unsaved content.'), actions: [TextButton(onPressed: ()=>Navigator.pop(c,false), child: const Text('Cancel')), FilledButton(onPressed: ()=>Navigator.pop(c,true), child: const Text('Discard'))]));
    if (confirm == true && mounted) Navigator.of(context).pop();
  }

  Future<void> _send() async {
    if (_parseEmails(_to.text).isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one valid recipient.'))); return; }
    if (_parseEmails(_cc.text, collectInvalid: true).isNotEmpty || _parseEmails(_bcc.text, collectInvalid: true).isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('One or more CC/BCC addresses are invalid.'))); return;
    }
    setState(() => _sending = true);
    final (ok, msg) = await ref.read(inboxControllerProvider.notifier).sendMessage(_buildMessage(folder: MailFolder.sent, draft: false));
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) {
      Navigator.of(context).pop();
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
      .replaceAll('\n', '<br />');
}

extension on String {
  String take(int max) => length <= max ? this : substring(0, max);
}

