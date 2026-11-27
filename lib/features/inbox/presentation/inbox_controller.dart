import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/app/bootstrap.dart';
import 'package:kmail_desktop/features/accounts/data/account_connection_state.dart';
import 'package:kmail_desktop/features/accounts/data/account_store.dart';
import 'package:kmail_desktop/features/accounts/data/mail_account_config.dart';
import 'package:kmail_desktop/features/inbox/presentation/inbox_state.dart';
import 'package:kmail_desktop/features/mail/data/mail_mime_mapper.dart';
import 'package:kmail_desktop/features/mail/data/mail_service.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final accountStoreProvider = Provider<AccountStore>((ref) {
  return AccountStore(ref.watch(sharedPreferencesProvider).requireValue);
});

final mailServiceProvider = Provider<MailService>((ref) => MailService());

class InboxController extends Notifier<InboxState> {
  final _uuid = const Uuid();
  late AccountStore _store;
  late MailService _mail;
  File? _cacheFile;
  Timer? _syncTimer;

  @override
  InboxState build() {
    ref.onDispose(() => _syncTimer?.cancel());
    _store = ref.watch(accountStoreProvider);
    _mail = ref.watch(mailServiceProvider);
    unawaited(_initialize());
    return const InboxState(syncStatus: SyncStatus.loading);
  }

  Future<void> _initialize() async {
    try {
      try {
        _cacheFile = await _cachePath();
      } catch (_) {
        // Cache locations can be unavailable in some runtimes; the cache
        // is optional, so fall through with no cached messages.
        _cacheFile = null;
      }
      final accounts = await _store.loadAccounts();
      final cached = await _loadCache();
      final selectedAccountId = accounts.isEmpty
          ? allAccountsId
          : (accounts.length > 1
              ? allAccountsId
              : (accounts.any((a) => a.isDefault)
                  ? accounts.firstWhere((a) => a.isDefault).id
                  : accounts.first.id));
      state = state.copyWith(
        accounts: accounts,
        messages: cached,
        selectedAccountId: selectedAccountId,
        selectedView:
            accounts.length > 1 ? MailboxView.allInboxes : MailboxView.inbox,
        syncStatus: SyncStatus.idle,
        clearError: true,
      );
      _ensureSelection();
      if (accounts.isNotEmpty) {
        unawaited(refresh());
        _syncTimer?.cancel();
        _syncTimer =
            Timer.periodic(const Duration(minutes: 5), (_) => refresh());
      }
    } catch (e) {
      state = state.copyWith(
          syncStatus: SyncStatus.error, error: _friendlyError(e));
    }
  }

  Future<File> _cachePath() async {
    try {
      final dir = await getApplicationSupportDirectory().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw StateError('cache path lookup timed out'),
      );
      await dir.create(recursive: true);
      return File(p.join(dir.path, 'kmail_cache.json'));
    } catch (_) {
      final fallbackDir = Directory(
        '${Directory.systemTemp.path}/kmail_cache_fallback_${DateTime.now().millisecondsSinceEpoch}',
      );
      return File('${fallbackDir.path}/kmail_cache.json');
    }
  }

  Future<List<EmailMessage>> _loadCache() async {
    try {
      final f = _cacheFile ?? await _cachePath();
      if (!f.existsSync()) return const [];
      final raw = jsonDecode(f.readAsStringSync());
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((m) => _messageFromJson(m.cast<String, dynamic>()))
          .whereType<EmailMessage>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveCache() async {
    try {
      final f = _cacheFile ?? await _cachePath();
      final data = state.messages.map(_messageToJson).toList();
      f.writeAsStringSync(jsonEncode(data));
    } catch (_) {}
  }

  // --- account management ---
  Future<String> addAccount(MailAccountConfig config, String password) async {
    final account =
        config.id.isEmpty ? config.copyWith(id: _uuid.v4()) : config;
    final accounts = [
      ...state.accounts.where((a) => a.id != account.id),
      account
    ];
    final normalized = _normalizeDefaults(accounts, account.id);
    await _store.saveAccounts(normalized);
    await _store.savePassword(account.id, password);
    final selected = normalized.length > 1 ? allAccountsId : account.id;
    state = state.copyWith(
      accounts: normalized,
      selectedAccountId: selected,
      selectedView:
          normalized.length > 1 ? MailboxView.allInboxes : MailboxView.inbox,
      clearError: true,
    );
    _ensureSelection();
    await refresh(accountId: account.id);
    return account.id;
  }

  Future<void> removeAccount(String accountId) async {
    await _store.deleteAccount(accountId);
    final accounts = state.accounts.where((a) => a.id != accountId).toList();
    final normalized = _normalizeDefaults(
        accounts, accounts.isNotEmpty ? accounts.first.id : null);
    final messages =
        state.messages.where((m) => m.accountId != accountId).toList();
    final selected = normalized.isEmpty
        ? allAccountsId
        : (state.selectedAccountId == accountId
            ? (normalized.any((a) => a.isDefault)
                ? normalized.firstWhere((a) => a.isDefault).id
                : normalized.first.id)
            : state.selectedAccountId);
    state = state.copyWith(
      accounts: normalized,
      messages: messages,
      selectedAccountId: selected,
      selectedView: normalized.length > 1 && selected == allAccountsId
          ? MailboxView.allInboxes
          : MailboxView.inbox,
      connectionStates: {...state.connectionStates}..remove(accountId),
      clearError: true,
    );
    _ensureSelection();
    await _saveCache();
  }

  Future<void> setDefaultAccount(String accountId) async {
    final normalized =
        _normalizeDefaults(state.accounts, accountId, makeDefault: true);
    await _store.saveAccounts(normalized);
    state = state.copyWith(accounts: normalized);
  }

  List<MailAccountConfig> _normalizeDefaults(
      List<MailAccountConfig> accounts, String? preferred,
      {bool makeDefault = false}) {
    if (accounts.isEmpty) return accounts;
    String? defaultId = preferred;
    if (!makeDefault) {
      for (final a in accounts) {
        if (a.isDefault) {
          defaultId = a.id;
          break;
        }
      }
      defaultId ??= preferred ?? accounts.first.id;
    }
    defaultId ??= accounts.first.id;
    if (!accounts.any((a) => a.id == defaultId)) defaultId = accounts.first.id;
    return [for (final a in accounts) a.copyWith(isDefault: a.id == defaultId)];
  }

  Future<(bool, String)> testAccount(
      MailAccountConfig config, String password) async {
    try {
      await _mail.testImap(config, password);
      await _mail.testSmtp(config, password);
      return (true, 'IMAP and SMTP connection successful.');
    } catch (e) {
      return (false, _friendlyError(e));
    }
  }

  Future<String?> getPassword(String accountId) =>
      _store.readPassword(accountId);

  // --- sync ---
  Future<void> refresh({String? accountId}) async {
    final targets = accountId != null
        ? state.accounts.where((a) => a.id == accountId).toList()
        : state.accounts;
    if (targets.isEmpty) return;
    state = state.copyWith(syncStatus: SyncStatus.syncing, clearError: true);
    final nextConnections = {...state.connectionStates};
    var merged = [...state.messages];
    String? firstError;
    for (final account in targets) {
      final pwd = await _store.readPassword(account.id);
      if (pwd == null || pwd.isEmpty) {
        nextConnections[account.id] = AccountConnectionState(
          account: account,
          error: 'Credentials missing. Edit account to reconnect.',
          requiresCredentials: true,
        );
        firstError ??= 'Credentials missing for ${account.email}.';
        continue;
      }
      try {
        nextConnections[account.id] =
            AccountConnectionState(account: account, isSyncing: true);
        state = state.copyWith(connectionStates: {...nextConnections});
        final inbox = await _mail.fetchRecentMessages(account, pwd,
            folder: MailFolder.inbox, limit: 40);
        final sent = await _mail.fetchRecentMessages(account, pwd,
            folder: MailFolder.sent, limit: 20);
        final drafts = await _mail.fetchRecentMessages(account, pwd,
            folder: MailFolder.drafts, limit: 20);
        final trash = await _mail.fetchRecentMessages(account, pwd,
            folder: MailFolder.trash, limit: 20);
        final spam = await _mail.fetchRecentMessages(account, pwd,
            folder: MailFolder.spam, limit: 20);
        final fetched = <EmailMessage>[
          ...inbox,
          ...sent,
          ...drafts,
          ...trash,
          ...spam
        ];
        merged = _mergeMessages(merged, fetched, account.id);
        nextConnections[account.id] = AccountConnectionState(
          account: account,
          isConnected: true,
          lastSyncedAt: DateTime.now(),
        );
      } catch (e) {
        final msg = _friendlyError(e);
        nextConnections[account.id] = AccountConnectionState(
          account: account,
          error: msg,
          requiresCredentials: _isAuthError(e),
        );
        firstError ??= msg;
      }
    }
    state = state.copyWith(
      messages: merged,
      syncStatus: firstError == null ? SyncStatus.success : SyncStatus.error,
      error: firstError,
      connectionStates: nextConnections,
    );
    _ensureSelection();
    await _saveCache();
  }

  List<EmailMessage> _mergeMessages(List<EmailMessage> existing,
      List<EmailMessage> fetched, String accountId) {
    final others = existing.where((m) => m.accountId != accountId).toList();
    final localDrafts = existing
        .where((m) =>
            m.accountId == accountId &&
            m.folder == MailFolder.drafts &&
            m.id.startsWith('local-'))
        .toList();
    final byId = <String, EmailMessage>{};
    for (final m in fetched) {
      byId[m.id] = m;
    }
    // preserve locally moved/deleted state? if user moved locally, server may still return in old folder - prefer server for now except local drafts
    for (final d in localDrafts) {
      byId.putIfAbsent(d.id, () => d);
    }
    return [...others, ...byId.values];
  }

  // --- selection/view/search ---
  void selectView(MailboxView view) {
    final next = state.copyWith(selectedView: view, selectedIds: <String>{});
    final visible = next.visibleMessages;
    state = next.copyWith(
        selectedMessageId: visible.isNotEmpty ? visible.first.id : null,
        clearSelectedMessage: visible.isEmpty);
  }

  void selectAccount(String accountId) {
    if (accountId != allAccountsId &&
        !state.accounts.any((a) => a.id == accountId)) return;
    final next = state.copyWith(
      selectedAccountId: accountId,
      selectedIds: <String>{},
      selectedView:
          accountId == allAccountsId && state.selectedView == MailboxView.inbox
              ? MailboxView.allInboxes
              : state.selectedView,
    );
    final visible = next.visibleMessages;
    state = next.copyWith(
        selectedMessageId: visible.isNotEmpty ? visible.first.id : null,
        clearSelectedMessage: visible.isEmpty);
  }

  void selectMessage(String id) {
    final msg = _byId(id);
    if (msg == null) return;
    state = state.copyWith(selectedMessageId: id);
    if (msg.isUnread) {
      unawaited(markRead(id, true));
    }
  }

  void toggleSelected(String id) {
    final next = {...state.selectedIds};
    if (!next.remove(id)) next.add(id);
    state = state.copyWith(selectedIds: next);
  }

  void clearSelection() => state = state.copyWith(selectedIds: <String>{});
  void selectAllVisible() => state = state.copyWith(
      selectedIds: state.visibleMessages.map((e) => e.id).toSet());

  void setSearch(String query) {
    final next = state.copyWith(searchQuery: query, selectedIds: <String>{});
    final visible = next.visibleMessages;
    final selectedStillVisible =
        visible.any((m) => m.id == next.selectedMessageId);
    state = next.copyWith(
      selectedMessageId: selectedStillVisible
          ? next.selectedMessageId
          : (visible.isNotEmpty ? visible.first.id : null),
      clearSelectedMessage: !selectedStillVisible && visible.isEmpty,
    );
  }

  void setSortNewestFirst(bool newestFirst) =>
      state = state.copyWith(sortNewestFirst: newestFirst);
  void toggleUnreadOnly() =>
      state = state.copyWith(filterUnreadOnly: !state.filterUnreadOnly);
  void toggleAttachmentsOnly() => state =
      state.copyWith(filterAttachmentsOnly: !state.filterAttachmentsOnly);

  // --- message actions ---
  Future<void> toggleStar(String id) async {
    final msg = _byId(id);
    if (msg == null) return;
    final next = !msg.isStarred;
    _updateMessage(id, (m) => m.copyWith(isStarred: next));
    await _syncFlag(msg, flagged: next);
  }

  Future<void> markRead(String id, bool read) async {
    final msg = _byId(id);
    if (msg == null) return;
    _updateMessage(id, (m) => m.copyWith(isUnread: !read));
    await _syncSeen(msg, seen: read);
  }

  Future<void> markSelectedRead(bool read) async {
    final ids = {...state.selectedIds};
    _updateMany(ids, (m) => m.copyWith(isUnread: !read));
    for (final id in ids) {
      final m = _byId(id);
      if (m != null) await _syncSeen(m, seen: read);
    }
  }

  Future<void> archiveSelected() async => moveSelectedTo(MailFolder.archive);
  Future<void> deleteSelected() async => moveSelectedTo(MailFolder.trash);
  Future<void> archiveMessage(String id) async =>
      moveTo(id, MailFolder.archive);
  Future<void> deleteMessage(String id) async => moveTo(id, MailFolder.trash);

  Future<void> moveSelectedTo(MailFolder folder) async {
    final ids = {...state.selectedIds};
    final originals = <EmailMessage>[
      for (final id in ids)
        if (_byId(id) != null) _byId(id)!
    ];
    _updateMany(ids, (m) => m.copyWith(folder: folder));
    state = state.copyWith(selectedIds: <String>{});
    _ensureSelectedVisible();
    for (final m in originals) {
      await _syncMove(m, folder);
    }
  }

  Future<void> moveTo(String id, MailFolder folder) async {
    final msg = _byId(id);
    if (msg == null) return;
    final original = msg;
    _updateMessage(id, (m) => m.copyWith(folder: folder));
    _ensureSelectedVisible();
    await _syncMove(original, folder);
  }

  Future<void> _syncSeen(EmailMessage msg, {required bool seen}) async {
    await _remoteOp(msg, (account, pwd) async {
      if (msg.remoteUid != null && msg.remoteMailbox != null) {
        await _mail.setSeen(account, pwd,
            uid: msg.remoteUid!, mailboxPath: msg.remoteMailbox!, seen: seen);
      }
    });
  }

  Future<void> _syncFlag(EmailMessage msg, {required bool flagged}) async {
    await _remoteOp(msg, (account, pwd) async {
      if (msg.remoteUid != null && msg.remoteMailbox != null) {
        await _mail.setFlagged(account, pwd,
            uid: msg.remoteUid!,
            mailboxPath: msg.remoteMailbox!,
            flagged: flagged);
      }
    });
  }

  Future<void> _syncMove(EmailMessage msg, MailFolder folder) async {
    await _remoteOp(msg, (account, pwd) async {
      if (msg.remoteUid != null && msg.remoteMailbox != null) {
        if (folder == MailFolder.trash) {
          await _mail.moveMessage(account, pwd,
              uid: msg.remoteUid!,
              fromMailboxPath: msg.remoteMailbox!,
              toFolder: MailFolder.trash);
        } else if (folder == MailFolder.archive) {
          await _mail.moveMessage(account, pwd,
              uid: msg.remoteUid!,
              fromMailboxPath: msg.remoteMailbox!,
              toFolder: MailFolder.archive);
        } else if (folder == MailFolder.spam) {
          await _mail.moveMessage(account, pwd,
              uid: msg.remoteUid!,
              fromMailboxPath: msg.remoteMailbox!,
              toFolder: MailFolder.spam);
        } else if (folder == MailFolder.inbox) {
          await _mail.moveMessage(account, pwd,
              uid: msg.remoteUid!,
              fromMailboxPath: msg.remoteMailbox!,
              toFolder: MailFolder.inbox);
        } else {
          await _mail.moveMessage(account, pwd,
              uid: msg.remoteUid!,
              fromMailboxPath: msg.remoteMailbox!,
              toFolder: folder);
        }
      }
    });
  }

  Future<void> _remoteOp(EmailMessage msg,
      Future<void> Function(MailAccountConfig, String) op) async {
    final account = state.accounts
        .where((a) => a.id == msg.accountId)
        .cast<MailAccountConfig?>()
        .firstWhere((a) => a != null, orElse: () => null);
    if (account == null) return;
    final pwd = await _store.readPassword(account.id);
    if (pwd == null || pwd.isEmpty) return;
    try {
      await op(account, pwd);
    } catch (e) {
      state = state.copyWith(
          error: _friendlyError(e), syncStatus: SyncStatus.error);
    }
  }

  Future<void> saveDraft(EmailMessage draft) async {
    final msg = draft.copyWith(folder: MailFolder.drafts, isDraft: true);
    final idx = state.messages.indexWhere((m) => m.id == msg.id);
    final msgs = [...state.messages];
    if (idx >= 0) {
      msgs[idx] = msg;
    } else {
      msgs.insert(0, msg);
    }
    state = state.copyWith(messages: msgs);
    await _saveCache();
  }

  Future<(bool, String)> sendMessage(EmailMessage message) async {
    final account = state.accounts
        .where((a) => a.id == message.accountId)
        .cast<MailAccountConfig?>()
        .firstWhere((a) => a != null, orElse: () => state.activeAccount);
    if (account == null)
      return (false, 'No account configured. Add an account in Settings.');
    final pwd = await _store.readPassword(account.id);
    if (pwd == null || pwd.isEmpty)
      return (
        false,
        'Credentials missing for ${account.email}. Edit the account.'
      );
    try {
      final mime = await MailMimeMapper.toMime(message.copyWith(
          sender:
              EmailAddress(name: account.displayName, email: account.email)));
      await _mail.sendMessage(account, pwd, mime);
      final sent = message.copyWith(
        id: message.id.startsWith('local-')
            ? message.id
            : 'local-sent-${_uuid.v4()}',
        accountId: account.id,
        folder: MailFolder.sent,
        isDraft: false,
        isUnread: false,
        date: DateTime.now(),
        sender: EmailAddress(name: account.displayName, email: account.email),
      );
      final msgs = [...state.messages.where((m) => m.id != sent.id)];
      msgs.insert(0, sent);
      state = state.copyWith(messages: msgs);
      await _saveCache();
      _ensureSelectedVisible();
      return (true, 'Message sent successfully.');
    } catch (e) {
      return (false, _friendlyError(e));
    }
  }

  EmailMessage? _byId(String id) {
    for (final m in state.messages) {
      if (m.id == id) return m;
    }
    return null;
  }

  void _updateMessage(String id, EmailMessage Function(EmailMessage) update) {
    state = state.copyWith(
        messages:
            state.messages.map((m) => m.id == id ? update(m) : m).toList());
    unawaited(_saveCache());
  }

  void _updateMany(
      Set<String> ids, EmailMessage Function(EmailMessage) update) {
    if (ids.isEmpty) return;
    state = state.copyWith(
        messages: state.messages
            .map((m) => ids.contains(m.id) ? update(m) : m)
            .toList());
    unawaited(_saveCache());
  }

  void _ensureSelection() {
    _ensureSelectedVisible();
  }

  void _ensureSelectedVisible() {
    final visible = state.visibleMessages;
    if (visible.any((m) => m.id == state.selectedMessageId)) return;
    state = state.copyWith(
        selectedMessageId: visible.isNotEmpty ? visible.first.id : null,
        clearSelectedMessage: visible.isEmpty);
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (_isAuthError(e))
      return 'Authentication failed. Check your email/password or app password and try again.';
    if (msg.contains('SocketException') ||
        msg.contains('timed out') ||
        msg.contains('Connection')) {
      return 'Unable to connect to the mail server. Check your internet connection and server settings.';
    }
    return 'Mail operation failed. Please try again later.';
  }

  bool _isAuthError(Object e) {
    final m = e.toString().toLowerCase();
    return m.contains('auth') ||
        m.contains('login') ||
        m.contains('credential') ||
        m.contains('535');
  }

  // --- cache serialization ---
  Map<String, dynamic> _messageToJson(EmailMessage m) => {
        'id': m.id,
        'accountId': m.accountId,
        'folder': m.folder.name,
        'sender': {'name': m.sender.name, 'email': m.sender.email},
        'to': m.to.map((e) => {'name': e.name, 'email': e.email}).toList(),
        'cc': m.cc.map((e) => {'name': e.name, 'email': e.email}).toList(),
        'bcc': m.bcc.map((e) => {'name': e.name, 'email': e.email}).toList(),
        'subject': m.subject,
        'preview': m.preview,
        'bodyPlainText': m.bodyPlainText,
        'bodyHtml': m.bodyHtml,
        'date': m.date.toIso8601String(),
        'isUnread': m.isUnread,
        'isStarred': m.isStarred,
        'labels': m.labels,
        'hasRemoteImages': m.hasRemoteImages,
        'isDraft': m.isDraft,
        'attachments': m.attachments
            .map((a) => {
                  'id': a.id,
                  'name': a.name,
                  'type': a.type.name,
                  'sizeBytes': a.sizeBytes,
                  'previewText': a.previewText,
                  'localPath': a.localPath,
                })
            .toList(),
        'remoteUid': m.remoteUid,
        'remoteMailbox': m.remoteMailbox,
      };

  EmailMessage? _messageFromJson(Map<String, dynamic> j) {
    try {
      EmailAddress addr(Map<String, dynamic> m) => EmailAddress(
          name: m['name'] as String? ?? '', email: m['email'] as String? ?? '');
      final folder = MailFolder.values
          .where((f) => f.name == j['folder'])
          .cast<MailFolder?>()
          .firstWhere((f) => f != null, orElse: () => MailFolder.inbox)!;
      return EmailMessage(
        id: j['id'] as String? ?? _uuid.v4(),
        accountId: j['accountId'] as String? ?? '',
        folder: folder,
        sender: addr((j['sender'] as Map).cast<String, dynamic>()),
        to: ((j['to'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => addr(e.cast<String, dynamic>()))
            .toList(),
        cc: ((j['cc'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => addr(e.cast<String, dynamic>()))
            .toList(),
        bcc: ((j['bcc'] as List?) ?? [])
            .whereType<Map>()
            .map((e) => addr(e.cast<String, dynamic>()))
            .toList(),
        subject: j['subject'] as String? ?? '',
        preview: j['preview'] as String? ?? '',
        bodyPlainText: j['bodyPlainText'] as String? ?? '',
        bodyHtml: j['bodyHtml'] as String? ?? '',
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        isUnread: j['isUnread'] as bool? ?? false,
        isStarred: j['isStarred'] as bool? ?? false,
        labels: ((j['labels'] as List?) ?? []).whereType<String>().toList(),
        hasRemoteImages: j['hasRemoteImages'] as bool? ?? false,
        isDraft: j['isDraft'] as bool? ?? false,
        attachments:
            ((j['attachments'] as List?) ?? []).whereType<Map>().map((a) {
          final m = a.cast<String, dynamic>();
          final type = AttachmentType.values
              .where((t) => t.name == m['type'])
              .cast<AttachmentType?>()
              .firstWhere((t) => t != null,
                  orElse: () => AttachmentType.unknown)!;
          return Attachment(
            id: m['id'] as String? ?? _uuid.v4(),
            name: m['name'] as String? ?? 'attachment',
            type: type,
            sizeBytes: (m['sizeBytes'] as num?)?.toInt() ?? 0,
            previewText: m['previewText'] as String?,
            localPath: m['localPath'] as String?,
          );
        }).toList(),
        remoteUid: (j['remoteUid'] as num?)?.toInt(),
        remoteMailbox: j['remoteMailbox'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

final inboxControllerProvider =
    NotifierProvider<InboxController, InboxState>(InboxController.new);
