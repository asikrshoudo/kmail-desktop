
import 'package:flutter/material.dart';
import 'package:kmail_desktop/features/accounts/data/account_connection_state.dart';
import 'package:kmail_desktop/features/accounts/data/mail_account_config.dart';
import 'package:kmail_desktop/shared/models/folder_item.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

const allAccountsId = 'all';

enum SyncStatus { idle, loading, syncing, success, error }

class InboxState {
  const InboxState({
    this.accounts = const [],
    this.messages = const [],
    this.selectedAccountId = allAccountsId,
    this.selectedView = MailboxView.allInboxes,
    this.selectedMessageId,
    this.selectedIds = const <String>{},
    this.searchQuery = '',
    this.sortNewestFirst = true,
    this.filterUnreadOnly = false,
    this.filterAttachmentsOnly = false,
    this.syncStatus = SyncStatus.idle,
    this.error,
    this.connectionStates = const {},
  });

  final List<MailAccountConfig> accounts;
  final List<EmailMessage> messages;
  final String selectedAccountId;
  final MailboxView selectedView;
  final String? selectedMessageId;
  final Set<String> selectedIds;
  final String searchQuery;
  final bool sortNewestFirst;
  final bool filterUnreadOnly;
  final bool filterAttachmentsOnly;
  final SyncStatus syncStatus;
  final String? error;
  final Map<String, AccountConnectionState> connectionStates;

  bool get hasAccounts => accounts.isNotEmpty;
  bool get isUnified => selectedAccountId == allAccountsId;
  bool get isLoading => syncStatus == SyncStatus.loading;
  bool get isSyncing => syncStatus == SyncStatus.syncing;

  MailAccountConfig? get activeAccount {
    if (accounts.isEmpty) return null;
    if (isUnified) {
      for (final a in accounts) {
        if (a.isDefault) return a;
      }
      return accounts.first;
    }
    for (final a in accounts) {
      if (a.id == selectedAccountId) return a;
    }
    return accounts.first;
  }

  InboxState copyWith({
    List<MailAccountConfig>? accounts,
    List<EmailMessage>? messages,
    String? selectedAccountId,
    MailboxView? selectedView,
    String? selectedMessageId,
    Set<String>? selectedIds,
    String? searchQuery,
    bool? sortNewestFirst,
    bool? filterUnreadOnly,
    bool? filterAttachmentsOnly,
    SyncStatus? syncStatus,
    String? error,
    bool clearError = false,
    Map<String, AccountConnectionState>? connectionStates,
    bool clearSelectedMessage = false,
  }) {
    return InboxState(
      accounts: accounts ?? this.accounts,
      messages: messages ?? this.messages,
      selectedAccountId: selectedAccountId ?? this.selectedAccountId,
      selectedView: selectedView ?? this.selectedView,
      selectedMessageId: clearSelectedMessage ? null : (selectedMessageId ?? this.selectedMessageId),
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      sortNewestFirst: sortNewestFirst ?? this.sortNewestFirst,
      filterUnreadOnly: filterUnreadOnly ?? this.filterUnreadOnly,
      filterAttachmentsOnly: filterAttachmentsOnly ?? this.filterAttachmentsOnly,
      syncStatus: syncStatus ?? this.syncStatus,
      error: clearError ? null : (error ?? this.error),
      connectionStates: connectionStates ?? this.connectionStates,
    );
  }

  List<EmailMessage> get scopedMessages {
    if (!hasAccounts) return const [];
    if (isUnified) return messages;
    return messages.where((m) => m.accountId == selectedAccountId).toList();
  }

  List<EmailMessage> get visibleMessages {
    final q = searchQuery.trim().toLowerCase();
    final scoped = scopedMessages.where((m) {
      final inView = switch (selectedView) {
        MailboxView.allInboxes => m.folder == MailFolder.inbox,
        MailboxView.starred => m.isStarred && m.folder != MailFolder.trash,
        MailboxView.unread => m.isUnread && m.folder != MailFolder.trash,
        MailboxView.inbox => m.folder == MailFolder.inbox,
        MailboxView.drafts => m.folder == MailFolder.drafts,
        MailboxView.sent => m.folder == MailFolder.sent,
        MailboxView.spam => m.folder == MailFolder.spam,
        MailboxView.trash => m.folder == MailFolder.trash,
      };
      if (!inView) return false;
      if (filterUnreadOnly && !m.isUnread) return false;
      if (filterAttachmentsOnly && !m.hasAttachments) return false;
      if (q.isEmpty) return true;
      final haystack = [
        m.sender.name, m.sender.email, m.subject, m.preview, m.bodyPlainText,
        ...m.to.map((e) => e.email), ...m.to.map((e) => e.name),
        ...m.cc.map((e) => e.email), ...m.bcc.map((e) => e.email),
        ...m.labels,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
    scoped.sort((a, b) => sortNewestFirst ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return scoped;
  }

  EmailMessage? get selectedMessage {
    final id = selectedMessageId;
    if (id == null) return null;
    for (final m in messages) {
      if (m.id == id) return m;
    }
    return null;
  }

  int countView(MailboxView view) {
    return scopedMessages.where((m) => _matchesView(m, view)).length;
  }

  static bool _matchesView(EmailMessage m, MailboxView view) => switch (view) {
    MailboxView.allInboxes => m.folder == MailFolder.inbox,
    MailboxView.starred => m.isStarred && m.folder != MailFolder.trash,
    MailboxView.unread => m.isUnread && m.folder != MailFolder.trash,
    MailboxView.inbox => m.folder == MailFolder.inbox,
    MailboxView.drafts => m.folder == MailFolder.drafts,
    MailboxView.sent => m.folder == MailFolder.sent,
    MailboxView.spam => m.folder == MailFolder.spam,
    MailboxView.trash => m.folder == MailFolder.trash,
  };

  List<FolderItem> get folders => [
    FolderItem(id: 'all-inboxes', label: 'All Inboxes', icon: Icons.all_inbox_rounded, view: MailboxView.allInboxes, count: countView(MailboxView.allInboxes)),
    FolderItem(id: 'starred', label: 'Starred', icon: Icons.star_outline_rounded, view: MailboxView.starred, count: countView(MailboxView.starred)),
    FolderItem(id: 'unread', label: 'Unread', icon: Icons.mark_email_unread_outlined, view: MailboxView.unread, count: countView(MailboxView.unread)),
    FolderItem(id: 'inbox', label: 'Inbox', icon: Icons.inbox_rounded, view: MailboxView.inbox, count: countView(MailboxView.inbox)),
    FolderItem(id: 'drafts', label: 'Drafts', icon: Icons.drafts_outlined, view: MailboxView.drafts, count: countView(MailboxView.drafts)),
    FolderItem(id: 'sent', label: 'Sent', icon: Icons.send_outlined, view: MailboxView.sent, count: countView(MailboxView.sent)),
    FolderItem(id: 'spam', label: 'Spam', icon: Icons.report_gmailerrorred_outlined, view: MailboxView.spam, count: countView(MailboxView.spam)),
    FolderItem(id: 'trash', label: 'Trash', icon: Icons.delete_outline_rounded, view: MailboxView.trash, count: countView(MailboxView.trash)),
  ];
}
