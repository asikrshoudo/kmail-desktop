import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kmail_desktop/features/accounts/data/mail_account_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CredentialStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class SecureCredentialStorage implements CredentialStorage {
  SecureCredentialStorage([FlutterSecureStorage? secure])
      : _secure = secure ?? const FlutterSecureStorage();
  final FlutterSecureStorage _secure;
  @override
  Future<void> write(String key, String value) =>
      _secure.write(key: key, value: value);
  @override
  Future<String?> read(String key) => _secure.read(key: key);
  @override
  Future<void> delete(String key) => _secure.delete(key: key);
}

class MemoryCredentialStorage implements CredentialStorage {
  final Map<String, String> _data = {};
  @override
  Future<void> write(String key, String value) async => _data[key] = value;
  @override
  Future<String?> read(String key) async => _data[key];
  @override
  Future<void> delete(String key) async => _data.remove(key);
}

class AccountStore {
  AccountStore(this._prefs, [CredentialStorage? credentials])
      : _credentials = credentials ?? SecureCredentialStorage();

  static const _accountsKey = 'accounts.v1';

  final SharedPreferences _prefs;
  final CredentialStorage _credentials;

  Future<List<MailAccountConfig>> loadAccounts() async {
    final raw = _prefs.getString(_accountsKey);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => MailAccountConfig.fromJson(e.cast<String, dynamic>()))
        .where((a) => a.id.isNotEmpty && a.email.isNotEmpty)
        .toList();
  }

  Future<void> saveAccounts(List<MailAccountConfig> accounts) async {
    final ids = accounts.map((a) => a.id).toSet();
    final existing = await loadAccounts();
    for (final old in existing) {
      if (!ids.contains(old.id)) {
        await _credentials.delete(_passwordKey(old.id));
      }
    }
    await _prefs.setString(
      _accountsKey,
      jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );
  }

  Future<void> savePassword(String accountId, String password) async {
    await _credentials.write(_passwordKey(accountId), password);
  }

  Future<String?> readPassword(String accountId) async {
    return _credentials.read(_passwordKey(accountId));
  }

  Future<void> deleteAccount(String accountId) async {
    final accounts = await loadAccounts();
    accounts.removeWhere((a) => a.id == accountId);
    await saveAccounts(accounts);
    await _credentials.delete(_passwordKey(accountId));
  }

  String _passwordKey(String id) => 'account.password.$id';
}
