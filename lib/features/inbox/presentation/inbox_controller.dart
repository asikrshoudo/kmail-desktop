import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kmail_desktop/features/inbox/data/mock_mail_repository.dart';
import 'package:kmail_desktop/shared/models/folder_item.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class InboxState {
  const InboxState({
    required this.account,
    required this.messages,
    required this.selectedFolder,
    required this.selectedMessageId,
    required this.selectedIds,
    required this.searchQuery,
    required this.sortNewestFirst,
    this.filterUnreadOnly = false,
    this.filterAttachmentsOnly = false,
  });

  final MailAccount account;
  final List<EmailMessage> messages;
  final MailFolder selectedFolder;
  final String? selectedMessageId;
  final Set<String> selectedIds;
  final String searchQuery;
  final bool sortNewestFirst;
  final bool filterUnreadOnly;
  final bool filterAttachmentsOnly;

  InboxState copyWith({
    MailAccount? account,
    List<EmailMessage>? messages,
    MailFolder? selectedFolder,
    String? selectedMessageId,
    Set<String>? selectedIds,
    String? searchQuery,
    bool? sortNewestFirst,
    bool? filterUnreadOnly,
    bool? filterAttachmentsOnly,
    bool clearSelectedMessage = false,
  }) {
    return InboxState(
      account: account ?? this.account,
      messages: messages ?? this.messages,
      selectedFolder: selectedFolder ?? this.selectedFolder,
      selectedMessageId: clearSelectedMessage ? null : (selectedMessageId ?? this.selectedMessageId),
      selectedIds: selectedIds ?? this.selectedIds,
      searchQuery: searchQuery ?? this.searchQuery,
      sortNewestFirst: sortNewestFirst ?? this.sortNewestFirst,
      filterUnreadOnly: filterUnreadOnly ?? this.filterUnreadOnly,
      filterAttachmentsOnly: filterAttachmentsOnly ?? this.filterAttachmentsOnly,
    );
  }

  List<EmailMessage> get visibleMessages {
    final q = searchQuery.trim().toLowerCase();
    final filtered = messages.where((m) {
      final inFolder = switch (selectedFolder) {
        MailFolder.starred => m.isStarred && m.folder != MailFolder.trash,
        MailFolder.inbox => m.folder == MailFolder.inbox,
        MailFolder.snoozed => m.folder == MailFolder.snoozed,
        MailFolder.drafts => m.folder == MailFolder.drafts,
        MailFolder.sent => m.folder == MailFolder.sent,
        MailFolder.archive => m.folder == MailFolder.archive,
        MailFolder.spam => m.folder == MailFolder.spam,
        MailFolder.trash => m.folder == MailFolder.trash,
        MailFolder.custom => m.folder == MailFolder.custom,
      };
      if (!inFolder) return false;
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
    filtered.sort((a, b) => sortNewestFirst ? b.date.compareTo(a.date) : a.date.compareTo(b.date));
    return filtered;
  }

  EmailMessage? get selectedMessage {
    final id = selectedMessageId;
    if (id == null) return null;
    for (final m in messages) {
      if (m.id == id) return m;
    }
    return null;
  }

  List<FolderItem> get folders {
    int count(MailFolder f) => messages.where((m) => m.folder == f).length;
    final starred = messages.where((m) => m.isStarred && m.folder != MailFolder.trash).length;
    return [
      FolderItem(id: 'inbox', label: 'Inbox', icon: _iconInbox, folder: MailFolder.inbox, count: count(MailFolder.inbox)),
      FolderItem(id: 'starred', label: 'Starred', icon: _iconStar, folder: MailFolder.starred, count: starred),
      FolderItem(id: 'snoozed', label: 'Snoozed', icon: _iconSnooze, folder: MailFolder.snoozed, count: count(MailFolder.snoozed)),
      FolderItem(id: 'drafts', label: 'Drafts', icon: _iconDrafts, folder: MailFolder.drafts, count: count(MailFolder.drafts)),
      FolderItem(id: 'sent', label: 'Sent', icon: _iconSent, folder: MailFolder.sent, count: count(MailFolder.sent)),
      FolderItem(id: 'archive', label: 'Archive', icon: _iconArchive, folder: MailFolder.archive, count: count(MailFolder.archive)),
      FolderItem(id: 'spam', label: 'Spam', icon: _iconSpam, folder: MailFolder.spam, count: count(MailFolder.spam)),
      FolderItem(id: 'trash', label: 'Trash', icon: _iconTrash, folder: MailFolder.trash, count: count(MailFolder.trash)),
    ];
  }
}

const _iconInbox = IconData(0xe156, fontFamily: 'MaterialIcons');
const _iconStar = IconData(0xe5f9, fontFamily: 'MaterialIcons');
const _iconSnooze = IconData(0xe046, fontFamily: 'MaterialIcons');
const _iconDrafts = IconData(0xe151, fontFamily: 'MaterialIcons');
const _iconSent = IconData(0xe163, fontFamily: 'MaterialIcons');
const _iconArchive = IconData(0xe149, fontFamily: 'MaterialIcons');
const _iconSpam = IconData(0xe002, fontFamily: 'MaterialIcons');
const _iconTrash = IconData(0xe872, fontFamily: 'MaterialIcons');

class InboxController extends Notifier<InboxState> {
  @override
  InboxState build() {
    final messages = MockMailRepository.initialMessages();
    final inbox = messages.where((m) => m.folder == MailFolder.inbox).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return InboxState(
      account: MockMailRepository.account,
      messages: messages,
      selectedFolder: MailFolder.inbox,
      selectedMessageId: inbox.isNotEmpty ? inbox.first.id : null,
      selectedIds: <String>{},
      searchQuery: '',
      sortNewestFirst: true,
    );
  }

  void selectFolder(MailFolder folder) {
    final next = state.copyWith(selectedFolder: folder, selectedIds: <String>{});
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
    state = state.copyWith(selectedIds: state.visibleMessages.map((e) => e.id).toSet());
  }

  void setSearch(String query) {
    final next = state.copyWith(searchQuery: query, selectedIds: <String>{});
    final visible = next.visibleMessages;
    final selectedStillVisible = visible.any((m) => m.id == next.selectedMessageId);
    state = next.copyWith(
      selectedMessageId: selectedStillVisible ? next.selectedMessageId : (visible.isNotEmpty ? visible.first.id : null),
      clearSelectedMessage: !selectedStillVisible && visible.isEmpty,
    );
  }

  void setSortNewestFirst(bool newestFirst) => state = state.copyWith(sortNewestFirst: newestFirst);
  void toggleUnreadOnly() => state = state.copyWith(filterUnreadOnly: !state.filterUnreadOnly);
  void toggleAttachmentsOnly() => state = state.copyWith(filterAttachmentsOnly: !state.filterAttachmentsOnly);

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
    final sent = message.copyWith(folder: MailFolder.sent, isDraft: false, date: DateTime.now());
    saveDraft(sent);
    if (state.selectedFolder == MailFolder.drafts) {
      _ensureSelectedVisible();
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
      messages: state.messages.map((m) => m.id == id ? update(m) : m).toList(),
    );
  }

  void _updateMany(Set<String> ids, EmailMessage Function(EmailMessage) update) {
    if (ids.isEmpty) return;
    state = state.copyWith(
      messages: state.messages.map((m) => ids.contains(m.id) ? update(m) : m).toList(),
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

final inboxControllerProvider = NotifierProvider<InboxController, InboxState>(InboxController.new);

