import 'package:flutter/foundation.dart';
import 'package:kmail_desktop/features/accounts/data/mail_account_config.dart';

@immutable
class AccountConnectionState {
  const AccountConnectionState({
    required this.account,
    this.isConnected = false,
    this.isSyncing = false,
    this.lastSyncedAt,
    this.error,
    this.requiresCredentials = false,
  });

  final MailAccountConfig account;
  final bool isConnected;
  final bool isSyncing;
  final DateTime? lastSyncedAt;
  final String? error;
  final bool requiresCredentials;

  AccountConnectionState copyWith({
    MailAccountConfig? account,
    bool? isConnected,
    bool? isSyncing,
    DateTime? lastSyncedAt,
    String? error,
    bool clearError = false,
    bool? requiresCredentials,
  }) {
    return AccountConnectionState(
      account: account ?? this.account,
      isConnected: isConnected ?? this.isConnected,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      error: clearError ? null : (error ?? this.error),
      requiresCredentials: requiresCredentials ?? this.requiresCredentials,
    );
  }
}
