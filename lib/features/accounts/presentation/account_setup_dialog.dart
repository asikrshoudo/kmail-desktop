import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_radii.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/accounts/data/mail_account_config.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_controller.dart';
import 'package:uuid/uuid.dart';

class AccountSetupDialog extends ConsumerStatefulWidget {
  const AccountSetupDialog({super.key, this.existing});
  final MailAccountConfig? existing;

  @override
  ConsumerState<AccountSetupDialog> createState() => _AccountSetupDialogState();
}

class _AccountSetupDialogState extends ConsumerState<AccountSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _imapHost = TextEditingController();
  final _imapPort = TextEditingController(text: '993');
  final _smtpHost = TextEditingController();
  final _smtpPort = TextEditingController(text: '587');
  MailSecurity _imapSecurity = MailSecurity.sslTls;
  MailSecurity _smtpSecurity = MailSecurity.startTls;
  bool _testing = false;
  bool _saving = false;
  bool _makeDefault = false;
  String? _status;
  bool _statusOk = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _name.text = e.displayName;
      _email.text = e.email;
      _username.text = e.username;
      _imapHost.text = e.imapHost;
      _imapPort.text = e.imapPort.toString();
      _smtpHost.text = e.smtpHost;
      _smtpPort.text = e.smtpPort.toString();
      _imapSecurity = e.imapSecurity;
      _smtpSecurity = e.smtpSecurity;
      _makeDefault = e.isDefault;
    }
    _email.addListener(_autoFill);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _username.dispose();
    _password.dispose();
    _imapHost.dispose();
    _imapPort.dispose();
    _smtpHost.dispose();
    _smtpPort.dispose();
    super.dispose();
  }

  void _autoFill() {
    final email = _email.text.trim();
    if (_username.text.trim().isEmpty) _username.text = email;
    final domain =
        email.contains('@') ? email.split('@').last.toLowerCase() : '';
    final preset = _presets[domain];
    if (preset == null) return;
    if (_imapHost.text.trim().isEmpty) _imapHost.text = preset.imapHost;
    if (_smtpHost.text.trim().isEmpty) _smtpHost.text = preset.smtpHost;
    _imapPort.text = preset.imapPort.toString();
    _smtpPort.text = preset.smtpPort.toString();
    setState(() {
      _imapSecurity = preset.imapSecurity;
      _smtpSecurity = preset.smtpSecurity;
    });
  }

  MailAccountConfig _buildConfig() {
    final existing = widget.existing;
    return MailAccountConfig(
      id: existing?.id ?? const Uuid().v4(),
      displayName: _name.text.trim(),
      email: _email.text.trim(),
      imapHost: _imapHost.text.trim(),
      imapPort: int.tryParse(_imapPort.text.trim()) ?? 993,
      imapSecurity: _imapSecurity,
      smtpHost: _smtpHost.text.trim(),
      smtpPort: int.tryParse(_smtpPort.text.trim()) ?? 587,
      smtpSecurity: _smtpSecurity,
      username: _username.text.trim().isEmpty
          ? _email.text.trim()
          : _username.text.trim(),
      isDefault: _makeDefault || (existing?.isDefault ?? false),
      colorValue: existing?.colorValue ?? _colorFor(_email.text.trim()),
    );
  }

  int _colorFor(String email) {
    const colors = [0xFF1F4B99, 0xFF0F766E, 0xFF7C3AED, 0xFFB45309, 0xFFBE123C];
    return colors[email.hashCode.abs() % colors.length];
  }

  Future<void> _test() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text.isEmpty && widget.existing == null) {
      setState(() {
        _status = 'Enter a password or app password to test the connection.';
        _statusOk = false;
      });
      return;
    }
    setState(() {
      _testing = true;
      _status = null;
    });
    final cfg = _buildConfig();
    final pwd = _password.text.isNotEmpty
        ? _password.text
        : (await ref
                .read(inboxControllerProvider.notifier)
                .getPassword(cfg.id) ??
            '');
    if (pwd.isEmpty) {
      setState(() {
        _testing = false;
        _status = 'Password required for connection test.';
        _statusOk = false;
      });
      return;
    }
    final (ok, msg) =
        await ref.read(inboxControllerProvider.notifier).testAccount(cfg, pwd);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _status = msg;
      _statusOk = ok;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text.isEmpty && widget.existing == null) {
      setState(() {
        _status = 'Password or app password is required to add an account.';
        _statusOk = false;
      });
      return;
    }
    setState(() {
      _saving = true;
      _status = null;
    });
    final cfg = _buildConfig();
    final controller = ref.read(inboxControllerProvider.notifier);
    var pwd = _password.text;
    if (pwd.isEmpty && widget.existing != null) {
      pwd = await controller.getPassword(widget.existing!.id) ?? '';
    }
    if (pwd.isEmpty) {
      setState(() {
        _saving = false;
        _status = 'Password is required.';
        _statusOk = false;
      });
      return;
    }
    final (ok, msg) = await controller.testAccount(cfg, pwd);
    if (!ok) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _status = msg;
        _statusOk = false;
      });
      return;
    }
    await controller.addAccount(cfg, pwd);
    if (_makeDefault) await controller.setDefaultAccount(cfg.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(widget.existing == null
            ? 'Account connected.'
            : 'Account updated.')));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors.tokens;
    final isEdit = widget.existing != null;
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(children: [
                Expanded(
                    child: Text(isEdit ? 'Edit account' : 'Add email account',
                        style: Theme.of(context).textTheme.headlineSmall)),
                IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded)),
              ]),
              const SizedBox(height: 8),
              Expanded(
                  child: Form(
                key: _formKey,
                child: ListView(children: [
                  Text(
                      'Connect an existing email account using IMAP and SMTP. Kmail does not provide email hosting.',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.md),
                  _section(context, 'Account', [
                    _field(_name, 'Display name', validator: _req),
                    _field(_email, 'Email address',
                        validator: _emailValidator,
                        keyboard: TextInputType.emailAddress),
                    _field(_username, 'Username', validator: _req),
                    _field(
                        _password,
                        isEdit
                            ? 'Password / app password (leave blank to keep existing)'
                            : 'Password / app password',
                        obscure: true,
                        validator: isEdit ? null : _req),
                  ]),
                  _section(context, 'Incoming IMAP', [
                    _field(_imapHost, 'IMAP host', validator: _req),
                    Row(children: [
                      Expanded(
                          child: _field(_imapPort, 'Port',
                              validator: _portValidator,
                              keyboard: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _securityDropdown('Security', _imapSecurity,
                              (v) => setState(() => _imapSecurity = v))),
                    ]),
                  ]),
                  _section(context, 'Outgoing SMTP', [
                    _field(_smtpHost, 'SMTP host', validator: _req),
                    Row(children: [
                      Expanded(
                          child: _field(_smtpPort, 'Port',
                              validator: _portValidator,
                              keyboard: TextInputType.number)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _securityDropdown('Security', _smtpSecurity,
                              (v) => setState(() => _smtpSecurity = v))),
                    ]),
                  ]),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _makeDefault,
                    onChanged: _saving
                        ? null
                        : (v) => setState(() => _makeDefault = v ?? false),
                    title: const Text('Set as default sending account'),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_status != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (_statusOk ? colors.success : colors.error)
                            .withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(
                            color: (_statusOk ? colors.success : colors.error)
                                .withValues(alpha: 0.25)),
                      ),
                      child: Text(_status!,
                          style: TextStyle(
                              color:
                                  _statusOk ? colors.success : colors.error)),
                    ),
                ]),
              )),
              const SizedBox(height: AppSpacing.md),
              Row(children: [
                OutlinedButton.icon(
                    onPressed: _testing || _saving ? null : _test,
                    icon: _testing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.wifi_tethering_rounded),
                    label: const Text('Test connection')),
                const Spacer(),
                TextButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    child: const Text('Cancel')),
                const SizedBox(width: 8),
                FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check_rounded),
                    label: Text(isEdit ? 'Save account' : 'Connect account')),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, List<Widget> children) {
    final colors = context.appColors.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        ...children.expand((w) => [w, const SizedBox(height: 10)]).toList()
          ..removeLast(),
      ]),
    );
  }

  Widget _field(TextEditingController c, String label,
      {String? Function(String?)? validator,
      bool obscure = false,
      TextInputType? keyboard}) {
    return TextFormField(
        controller: c,
        obscureText: obscure,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
        validator: validator);
  }

  Widget _securityDropdown(
      String label, MailSecurity value, ValueChanged<MailSecurity> onChanged) {
    String text(MailSecurity s) => switch (s) {
          MailSecurity.sslTls => 'SSL/TLS',
          MailSecurity.startTls => 'STARTTLS',
          MailSecurity.none => 'None (not recommended)'
        };
    return DropdownButtonFormField<MailSecurity>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final s in MailSecurity.values)
          DropdownMenuItem(value: s, child: Text(text(s)))
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  String? _req(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _portValidator(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null || n < 1 || n > 65535) return 'Invalid port';
    return null;
  }

  String? _emailValidator(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return 'Required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
    return ok ? null : 'Enter a valid email address';
  }
}

class _Preset {
  const _Preset(this.imapHost, this.imapPort, this.imapSecurity, this.smtpHost,
      this.smtpPort, this.smtpSecurity);
  final String imapHost;
  final int imapPort;
  final MailSecurity imapSecurity;
  final String smtpHost;
  final int smtpPort;
  final MailSecurity smtpSecurity;
}

const _presets = <String, _Preset>{
  'gmail.com': _Preset('imap.gmail.com', 993, MailSecurity.sslTls,
      'smtp.gmail.com', 587, MailSecurity.startTls),
  'googlemail.com': _Preset('imap.gmail.com', 993, MailSecurity.sslTls,
      'smtp.gmail.com', 587, MailSecurity.startTls),
  'outlook.com': _Preset('outlook.office365.com', 993, MailSecurity.sslTls,
      'smtp.office365.com', 587, MailSecurity.startTls),
  'hotmail.com': _Preset('outlook.office365.com', 993, MailSecurity.sslTls,
      'smtp.office365.com', 587, MailSecurity.startTls),
  'live.com': _Preset('outlook.office365.com', 993, MailSecurity.sslTls,
      'smtp.office365.com', 587, MailSecurity.startTls),
  'yahoo.com': _Preset('imap.mail.yahoo.com', 993, MailSecurity.sslTls,
      'smtp.mail.yahoo.com', 587, MailSecurity.startTls),
  'icloud.com': _Preset('imap.mail.me.com', 993, MailSecurity.sslTls,
      'smtp.mail.me.com', 587, MailSecurity.startTls),
};
