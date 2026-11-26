import 'package:flutter/foundation.dart';

enum MailSecurity { sslTls, startTls, none }

enum AccountAuthType { password }

@immutable
class MailAccountConfig {
  const MailAccountConfig({
    required this.id,
    required this.displayName,
    required this.email,
    required this.imapHost,
    required this.imapPort,
    required this.imapSecurity,
    required this.smtpHost,
    required this.smtpPort,
    required this.smtpSecurity,
    required this.username,
    this.authType = AccountAuthType.password,
    this.isDefault = false,
    this.colorValue = 0xFF1F4B99,
  });

  final String id;
  final String displayName;
  final String email;
  final String imapHost;
  final int imapPort;
  final MailSecurity imapSecurity;
  final String smtpHost;
  final int smtpPort;
  final MailSecurity smtpSecurity;
  final String username;
  final AccountAuthType authType;
  final bool isDefault;
  final int colorValue;

  MailAccountConfig copyWith({
    String? id,
    String? displayName,
    String? email,
    String? imapHost,
    int? imapPort,
    MailSecurity? imapSecurity,
    String? smtpHost,
    int? smtpPort,
    MailSecurity? smtpSecurity,
    String? username,
    AccountAuthType? authType,
    bool? isDefault,
    int? colorValue,
  }) {
    return MailAccountConfig(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      imapHost: imapHost ?? this.imapHost,
      imapPort: imapPort ?? this.imapPort,
      imapSecurity: imapSecurity ?? this.imapSecurity,
      smtpHost: smtpHost ?? this.smtpHost,
      smtpPort: smtpPort ?? this.smtpPort,
      smtpSecurity: smtpSecurity ?? this.smtpSecurity,
      username: username ?? this.username,
      authType: authType ?? this.authType,
      isDefault: isDefault ?? this.isDefault,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'email': email,
        'imapHost': imapHost,
        'imapPort': imapPort,
        'imapSecurity': imapSecurity.name,
        'smtpHost': smtpHost,
        'smtpPort': smtpPort,
        'smtpSecurity': smtpSecurity.name,
        'username': username,
        'authType': authType.name,
        'isDefault': isDefault,
        'colorValue': colorValue,
      };

  static MailAccountConfig fromJson(Map<String, dynamic> json) {
    MailSecurity sec(String? v, MailSecurity fallback) {
      for (final s in MailSecurity.values) {
        if (s.name == v) return s;
      }
      return fallback;
    }

    return MailAccountConfig(
      id: json['id'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      imapHost: json['imapHost'] as String? ?? '',
      imapPort: (json['imapPort'] as num?)?.toInt() ?? 993,
      imapSecurity: sec(json['imapSecurity'] as String?, MailSecurity.sslTls),
      smtpHost: json['smtpHost'] as String? ?? '',
      smtpPort: (json['smtpPort'] as num?)?.toInt() ?? 587,
      smtpSecurity: sec(json['smtpSecurity'] as String?, MailSecurity.startTls),
      username: json['username'] as String? ?? json['email'] as String? ?? '',
      authType: AccountAuthType.password,
      isDefault: json['isDefault'] as bool? ?? false,
      colorValue: (json['colorValue'] as num?)?.toInt() ?? 0xFF1F4B99,
    );
  }
}
