import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/features/inbox/data/mock_mail_repository.dart';
import 'package:kmail_desktop/shared/models/folder_item.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

const allAccountsId = 'all';

class InboxState {
  const InboxState({
    required this.accounts,
    required this.messages,
    required this.selectedAccountId,
    required this.selectedView,
    required this.selectedMessageId,
    required this.selectedIds,
    required this.searchQuery,
    required this.sortNewestFirst,
    this.filterUnreadOnly = false,
    this.filterAttachmentsOnly = false,
  });

  final List<MailAccount> accounts;
  final List<EmailMessage> messages;
  final String selectedAccountId; // account id or allAccountsId
  final MailboxView selectedView;
  final String? selectedMessageId;
  final Set<String> selectedIds;
  final String searchQuery;
  final bool sortNewestFirst;
  final bool filterUnreadOnly;
  final bool filterAttachmentsOnly;

  InboxState copyWith({
    List<MailAccount>? accounts,
    List<EmailMessage>? messages,
    String? selectedAccountId,
    MailboxView? selectedView,
    String? selectedMessageId,
    Set<String>? selectedIds,
    String? searchQuery,
    bool? sortNewestFirst,
    bool? filterUnreadOnly,
    bool? filterAttachmentsOnly,
    bool clearSelectedMessage = false,
  }) {
    return InboxState(
      accounts: accounts ?? this.accounts,
      messages: messages ?? this.messages,
      selectedAccountId: selectedAccountId ?? this.selectedAccountId,
      selectedView: selectedView ?? this.selectedView,
      selectedMessageId: clearSelectedMessage
          ? null
          : (selectedMessageId ?? this.selectedMessageId),
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      sortNewestFirst: sortNewestFirst ?? this.sortNewestFirst,
      filterUnreadOnly: filterUnreadOnly ?? this.filterUnreadOnly,
      filterAttachmentsOnly:
          filterAttachmentsOnly ?? this.filterAttachmentsOnly,
    );
  }

  bool get isUnified => selectedAccountId == allAccountsId;

  MailAccount? get activeAccount {
    if (isUnified) return null;
    for (final a in accounts) {
      if (a.id == selectedAccountId) return a;
    }
    return accounts.isNotEmpty ? accounts.first : null;
  }

  List<EmailMessage> get scopedMessages {
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
        m.sender.name,
        m.sender.email,
        m.subject,
        m.preview,
        m.bodyPlainText,
        ...m.to.map((e) => e.email),
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
    scoped.sort((a, b) =>
        sortNewestFirst ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
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
    final scoped = scopedMessages;
    return scoped.where((m) {
      return switch (view) {
        MailboxView.allInboxes => m.folder == MailFolder.inbox,
        MailboxView.starred => m.isStarred && m.folder != MailFolder.trash,
        MailboxView.unread => m.isUnread && m.folder != MailFolder.trash,
        MailboxView.inbox => m.folder == MailFolder.inbox,
        MailboxView.drafts => m.folder == MailFolder.drafts,
        MailboxView.sent => m.folder == MailFolder.sent,
        MailboxView.spam => m.folder == MailFolder.spam,
        MailboxView.trash => m.folder == MailFolder.trash,
      };
    }).length;
  }

  List<FolderItem> get folders {
    return [
      FolderItem(
          id: 'all-inboxes',
          label: 'All Inboxes',
          icon: const IconData(0xe88a, fontFamily: 'MaterialIcons'),
          view: MailboxView.allInboxes,
          count: countView(MailboxView.allInboxes)),
      FolderItem(
          id: 'starred',
          label: 'Starred',
          icon: const IconData(0xe5f9, fontFamily: 'MaterialIcons'),
          view: MailboxView.starred,
          count: countView(MailboxView.starred)),
      FolderItem(
          id: 'unread',
          label: 'Unread',
          icon: const IconData(0xe159, fontFamily: 'MaterialIcons'),
          view: MailboxView.unread,
          count: countView(MailboxView.unread)),
      FolderItem(
          id: 'inbox',
          label: 'Inbox',
          icon: const IconData(0xe156, fontFamily: 'MaterialIcons'),
          view: MailboxView.inbox,
          count: countView(MailboxView.inbox)),
      FolderItem(
          id: 'drafts',
          label: 'Drafts',
          icon: const IconData(0xe151, fontFamily: 'MaterialIcons'),
          view: MailboxView.drafts,
          count: countView(MailboxView.drafts)),
      FolderItem(
          id: 'sent',
          label: 'Sent',
          icon: const IconData(0xe163, fontFamily: 'MaterialIcons'),
          view: MailboxView.sent,
          count: countView(MailboxView.sent)),
      FolderItem(
          id: 'spam',
          label: 'Spam',
          icon: const IconData(0xe002, fontFamily: 'MaterialIcons'),
          view: MailboxView.spam,
          count: countView(MailboxView.spam)),
      FolderItem(
          id: 'trash',
          label: 'Trash',
          icon: const IconData(0xe872, fontFamily: 'MaterialIcons'),
          view: MailboxView.trash,
          count: countView(MailboxView.trash)),
    ];
  }
}

class InboxController extends Notifier<InboxState> {
  @override
  InboxState build() {
    final messages = MockMailRepository.initialMessages();
    final accounts = MockMailRepository.accounts;
    final defaultAccount = accounts.first;
    final inbox = messages
        .where((m) =>
            m.accountId == defaultAccount.id && m.folder == MailFolder.inbox)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return InboxState(
      accounts: accounts,
      messages: messages,
      selectedAccountId: defaultAccount.id,
      selectedView: MailboxView.inbox,
      selectedMessageId: inbox.isNotEmpty ? inbox.first.id : null,
      selectedIds: <String>{},
      searchQuery: '',
      sortNewestFirst: true,
    );
  }

  void selectView(MailboxView view) {
    final next = state.copyWith(selectedView: view, selectedIds: <String>{});
    final visible = next.visibleMessages;
    state = next.copyWith(
      selectedMessageId: visible.isNotEmpty ? visible.first.id : null,
      clearSelectedMessage: visible.isEmpty,
    );
  }

  void selectAccount(String accountId) {
    if (accountId != allAccountsId &&
        !state.accounts.any((a) => a.id == accountId)) {
      return;
    }
    final next = state.copyWith(
      selectedAccountId: accountId,
      selectedIds: <String>{},
      // When in unified mode, prefer All Inboxes for clarity.
      selectedView: accountId == allAccountsId &&
              state.selectedView == MailboxView.inbox
          ? MailboxView.allInboxes
          : state.selectedView,
    );
    final visible = next.visibleMessages;
    state = next.copyWith(
      selectedMessageId: visible.isNotEmpty ? visible.first.id : null,
      clearSelectedMessage: visible.isEmpty,
    );
  }

  void selectMessage(String id) {
    final msg = _byId(id);
    if (msg == null) return;
    state = state.copyWith(selectedMessageId: id);
    if (msg.isUnread) markRead(id, true);
  }

  void toggleSelected(String id) {
    final next = {...state.selectedIds};
    if (!next.remove(id)) next.add(id);
    state = state.copyWith(selectedIds: next);
  }

  void clearSelection() => state = state.copyWith(selectedIds: <String>{});

  void selectAllVisible() {
    state = state.copyWith(
        selectedIds: state.visibleMessages.map((e) => e.id).toSet());
  }

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

  void toggleStar(String id) {
    _updateMessage(id, (m) => m.copyWith(isStarred: !m.isStarred));
  }

  void markRead(String id, bool read) {
    _updateMessage(id, (m) => m.copyWith(isUnread: !read));
  }

  void markSelectedRead(bool read) {
    _updateMany(state.selectedIds, (m) => m.copyWith(isUnread: !read));
  }

  void archiveSelected() => moveSelectedTo(MailFolder.archive);
  void deleteSelected() => moveSelectedTo(MailFolder.trash);

  void archiveMessage(String id) => moveTo(id, MailFolder.archive);
  void deleteMessage(String id) => moveTo(id, MailFolder.trash);

  void moveSelectedTo(MailFolder folder) {
    _updateMany(state.selectedIds, (m) => m.copyWith(folder: folder));
    state = state.copyWith(selectedIds: <String>{});
    _ensureSelectedVisible();
  }

  void moveTo(String id, MailFolder folder) {
    _updateMessage(id, (m) => m.copyWith(folder: folder));
    _ensureSelectedVisible();
  }

  void saveDraft(EmailMessage draft) {
    final idx = state.messages.indexWhere((m) => m.id == draft.id);
    final msgs = [...state.messages];
    if (idx >= 0) {
      msgs[idx] = draft;
    } else {
      msgs.insert(0, draft);
    }
    state = state.copyWith(messages: msgs);
  }

  void sendMock(EmailMessage message) {
    final sent = message.copyWith(
        folder: MailFolder.sent, isDraft: false, date: DateTime.now());
    saveDraft(sent);
    _ensureSelectedVisible();
  }

  EmailMessage? _byId(String id) {
    for (final m in state.messages) {
      if (m.id == id) return m;
    }
    return null;
  }

  void _updateMessage(String id, EmailMessage Function(EmailMessage) update) {
    state = state.copyWith(
      messages: state.messages.map((m) => m.id == id ? update(m) : m).toList(),
    );
  }

  void _updateMany(
      Set<String> ids, EmailMessage Function(EmailMessage) update) {
    if (ids.isEmpty) return;
    state = state.copyWith(
      messages: state.messages
          .map((m) => ids.contains(m.id) ? update(m) : m)
          .toList(),
    );
  }

  void _ensureSelectedVisible() {
    final visible = state.visibleMessages;
    if (visible.any((m) => m.id == state.selectedMessageId)) return;
    state = state.copyWith(
      selectedMessageId: visible.isNotEmpty ? visible.first.id : null,
      clearSelectedMessage: visible.isEmpty,
    );
  }
}

final inboxControllerProvider =
    NotifierProvider<InboxController, InboxState>(InboxController.new);
