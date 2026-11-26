import 'package:kmail_desktop/shared/models/mail_models.dart';

class MockMailRepository {
  static const account = MailAccount(
    id: 'acc-1',
    name: 'Alex Morgan',
    email: 'alex.morgan@kmail.app',
    colorValue: 0xFF1F4B99,
    isDefault: true,
  );

  static List<EmailMessage> initialMessages() {
    final now = DateTime.now();
    return [
      EmailMessage(
        id: 'm1',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'Nora Patel', email: 'nora.patel@northwindstudio.com'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        cc: const [
          EmailAddress(name: 'Design Team', email: 'design@northwindstudio.com')
        ],
        subject: 'Updated brand review deck for tomorrow',
        preview:
            'I attached the revised deck with the updated palette and typography notes.',
        bodyPlainText:
            'Hi Alex,\n\nI attached the revised deck with the updated palette and typography notes. Please review slides 8-12 before tomorrow\'s meeting.\n\nThanks,\nNora',
        bodyHtml: '''
<div style="font-family:Segoe UI,Arial,sans-serif;color:#1f2937;line-height:1.6">
  <p>Hi Alex,</p>
  <p>I attached the revised deck with the updated <strong>palette</strong> and typography notes. Please review slides 8–12 before tomorrow's meeting.</p>
  <p style="margin-top:16px">Thanks,<br/>Nora</p>
</div>
''',
        date: now.subtract(const Duration(minutes: 18)),
        isUnread: true,
        isStarred: true,
        labels: const ['Work'],
        attachments: const [
          Attachment(
              id: 'a1',
              name: 'Brand-Review-Deck.pdf',
              type: AttachmentType.pdf,
              sizeBytes: 2457600),
        ],
      ),
      EmailMessage(
        id: 'm2',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(name: 'GitHub', email: 'noreply@github.com'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: '[kmail-desktop] Pull request review requested',
        preview:
            'You were requested to review PR #42: Improve inbox selection behavior.',
        bodyPlainText:
            'You were requested to review PR #42: Improve inbox selection behavior.\n\nRepository: asikrshoudo/kmail-desktop',
        bodyHtml: '''
<div style="font-family:Segoe UI,Arial,sans-serif;color:#1f2937;line-height:1.6">
  <h2 style="margin:0 0 12px 0;font-size:20px">Review requested</h2>
  <p>You were requested to review <strong>PR #42</strong>: Improve inbox selection behavior.</p>
  <table style="border-collapse:collapse;margin-top:12px">
    <tr><td style="padding:6px 12px 6px 0;color:#526071">Repository</td><td style="padding:6px 0"><strong>asikrshoudo/kmail-desktop</strong></td></tr>
    <tr><td style="padding:6px 12px 6px 0;color:#526071">Branch</td><td style="padding:6px 0">feature/inbox-selection</td></tr>
  </table>
  <p style="margin-top:16px"><a href="https://github.com/asikrshoudo/kmail-desktop/pull/42">Open pull request</a></p>
</div>
''',
        date: now.subtract(const Duration(hours: 1, minutes: 5)),
        isUnread: true,
        labels: const ['Dev'],
      ),
      EmailMessage(
        id: 'm3',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'Lena Fischer', email: 'lena.fischer@example.com'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Weekend hike photos',
        preview:
            'Here are a few photos from the trail. The weather was perfect.',
        bodyPlainText:
            'Hi Alex,\n\nHere are a few photos from the trail. The weather was perfect!\n\nLena',
        bodyHtml: '''
<div style="font-family:Segoe UI,Arial,sans-serif;color:#1f2937;line-height:1.6">
  <p>Hi Alex,</p>
  <p>Here are a few photos from the trail. The weather was perfect!</p>
  <p><img src="https://images.example.com/trail.jpg" alt="Trail photo" style="max-width:100%;border-radius:8px"/></p>
  <p>— Lena</p>
</div>
''',
        date: now.subtract(const Duration(hours: 3)),
        isUnread: false,
        isStarred: false,
        labels: const ['Personal'],
        attachments: const [
          Attachment(
              id: 'a3a',
              name: 'trail-photo.jpg',
              type: AttachmentType.jpg,
              sizeBytes: 1835008),
          Attachment(
              id: 'a3b',
              name: 'group-photo.png',
              type: AttachmentType.png,
              sizeBytes: 942080),
        ],
        hasRemoteImages: true,
      ),
      EmailMessage(
        id: 'm4',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'CloudInvoice', email: 'billing@cloudinvoice.example'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Your receipt for November workspace plan',
        preview: 'Thanks for your payment. Your receipt is attached.',
        bodyPlainText:
            'Thanks for your payment.\nAmount: \$24.00\nPlan: Workspace Plus\nInvoice: INV-2048',
        bodyHtml: '''
<div style="font-family:Segoe UI,Arial,sans-serif;color:#1f2937;line-height:1.6">
  <p>Thanks for your payment.</p>
  <table style="border-collapse:collapse;width:100%;max-width:420px">
    <tr><td style="padding:8px;border:1px solid #d9e2ec">Amount</td><td style="padding:8px;border:1px solid #d9e2ec"><strong>\$24.00</strong></td></tr>
    <tr><td style="padding:8px;border:1px solid #d9e2ec">Plan</td><td style="padding:8px;border:1px solid #d9e2ec">Workspace Plus</td></tr>
    <tr><td style="padding:8px;border:1px solid #d9e2ec">Invoice</td><td style="padding:8px;border:1px solid #d9e2ec">INV-2048</td></tr>
  </table>
</div>
''',
        date: now.subtract(const Duration(days: 1, hours: 2)),
        labels: const ['Receipts'],
        attachments: const [
          Attachment(
              id: 'a4',
              name: 'INV-2048.pdf',
              type: AttachmentType.pdf,
              sizeBytes: 184320),
        ],
      ),
      EmailMessage(
        id: 'm5',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'Product Weekly', email: 'newsletter@productweekly.example'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: '5 desktop UX patterns worth stealing',
        preview:
            'This week: command palettes, calm notifications, and better empty states.',
        bodyPlainText:
            'This week: command palettes, calm notifications, and better empty states.',
        bodyHtml: '''
<div style="font-family:Georgia,serif;color:#1f2937;line-height:1.7">
  <h1 style="font-size:28px;margin-bottom:8px">5 desktop UX patterns worth stealing</h1>
  <p style="color:#526071">This week: command palettes, calm notifications, and better empty states.</p>
  <ul>
    <li><strong>Command palettes</strong> for fast actions.</li>
    <li><strong>Calm notifications</strong> that respect focus.</li>
    <li><strong>Better empty states</strong> with clear next steps.</li>
  </ul>
  <p><a href="https://productweekly.example/issues/245">Read issue 245</a></p>
</div>
''',
        date: now.subtract(const Duration(days: 1, hours: 6)),
        labels: const ['Newsletter'],
        hasRemoteImages: true,
      ),
      EmailMessage(
        id: 'm6',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender:
            const EmailAddress(name: 'Maya Chen', email: 'maya.chen@kmail.app'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Re: Release checklist',
        preview:
            'I checked the signing step and added notes about artifact retention.',
        bodyPlainText:
            'I checked the signing step and added notes about artifact retention.\n\nOn Tue, Maya Chen wrote:\n> Can you review the release checklist?',
        bodyHtml: '''
<div style="font-family:Segoe UI,Arial,sans-serif;color:#1f2937;line-height:1.6">
  <p>I checked the signing step and added notes about artifact retention.</p>
  <blockquote style="margin:12px 0;padding-left:12px;border-left:3px solid #d9e2ec;color:#526071">
    On Tue, Maya Chen wrote:<br/>Can you review the release checklist?
  </blockquote>
</div>
''',
        date: now.subtract(const Duration(days: 2, hours: 3)),
        isUnread: false,
        labels: const ['Work'],
      ),
      EmailMessage(
        id: 'm7',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'Security Alerts', email: 'alerts@accounts.example'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'New sign-in from Windows device',
        preview:
            'We noticed a new sign-in to your account from a Windows device.',
        bodyPlainText:
            'We noticed a new sign-in to your account from a Windows device. If this was you, no action is needed.',
        bodyHtml: '''
<div style="font-family:Segoe UI,Arial,sans-serif;color:#1f2937;line-height:1.6">
  <p><strong>New sign-in detected</strong></p>
  <p>We noticed a new sign-in to your account from a Windows device.</p>
  <p>If this was you, no action is needed.</p>
</div>
''',
        date: now.subtract(const Duration(days: 2, hours: 9)),
        isUnread: true,
        labels: const ['Security'],
      ),
      EmailMessage(
        id: 'm8',
        accountId: account.id,
        folder: MailFolder.sent,
        sender: const EmailAddress(
            name: 'Alex Morgan', email: 'alex.morgan@kmail.app'),
        to: const [
          EmailAddress(
              name: 'Nora Patel', email: 'nora.patel@northwindstudio.com')
        ],
        subject: 'Re: Updated brand review deck for tomorrow',
        preview: 'Looks great — I left comments on slides 10 and 11.',
        bodyPlainText:
            'Looks great — I left comments on slides 10 and 11.\n\nAlex',
        bodyHtml:
            '<p>Looks great — I left comments on slides 10 and 11.</p><p>Alex</p>',
        date: now.subtract(const Duration(minutes: 5)),
      ),
      EmailMessage(
        id: 'm9',
        accountId: account.id,
        folder: MailFolder.drafts,
        sender: const EmailAddress(
            name: 'Alex Morgan', email: 'alex.morgan@kmail.app'),
        to: const [
          EmailAddress(name: 'Support Team', email: 'support@example.com')
        ],
        subject: 'Question about account export',
        preview:
            'Hi, I wanted to ask about the expected timeline for account export...',
        bodyPlainText:
            'Hi,\n\nI wanted to ask about the expected timeline for account export and whether it will support encrypted backups.\n\nBest,\nAlex',
        bodyHtml:
            '<p>Hi,</p><p>I wanted to ask about the expected timeline for account export and whether it will support encrypted backups.</p><p>Best,<br/>Alex</p>',
        date: now.subtract(const Duration(days: 3)),
        isDraft: true,
      ),
      EmailMessage(
        id: 'm10',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'Travel Desk', email: 'travel@wanderly.example'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Your itinerary for Lisbon',
        preview: 'Your trip confirmation and itinerary are ready.',
        bodyPlainText:
            'Your trip confirmation and itinerary are ready. Flight departs 09:20.',
        bodyHtml: '''
<div style="font-family:Segoe UI,Arial,sans-serif;color:#1f2937;line-height:1.6">
  <h2 style="margin-bottom:8px">Lisbon itinerary</h2>
  <p>Your trip confirmation and itinerary are ready.</p>
  <ul><li>Flight departs: 09:20</li><li>Hotel check-in: 15:00</li></ul>
</div>
''',
        date: now.subtract(const Duration(days: 4)),
        attachments: const [
          Attachment(
              id: 'a10',
              name: 'itinerary.pdf',
              type: AttachmentType.pdf,
              sizeBytes: 524288),
        ],
      ),
      EmailMessage(
        id: 'm11',
        accountId: account.id,
        folder: MailFolder.archive,
        sender: const EmailAddress(
            name: 'Design Digest', email: 'digest@designdigest.example'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Archived: April inspiration board',
        preview:
            'A collection of calm desktop interfaces and typography references.',
        bodyPlainText:
            'A collection of calm desktop interfaces and typography references.',
        bodyHtml:
            '<p>A collection of calm desktop interfaces and typography references.</p>',
        date: now.subtract(const Duration(days: 6)),
      ),
      EmailMessage(
        id: 'm12',
        accountId: account.id,
        folder: MailFolder.spam,
        sender: const EmailAddress(
            name: 'Unknown Prize', email: 'promo@unknown-prize.example'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'You won a suspicious prize',
        preview: 'Click immediately to claim your reward.',
        bodyPlainText: 'Click immediately to claim your reward.',
        bodyHtml:
            '<p>Click immediately to claim your reward. <a href="javascript:alert(1)">Claim</a></p><script>alert("bad")</script>',
        date: now.subtract(const Duration(days: 5)),
        isUnread: true,
      ),
      EmailMessage(
        id: 'm13',
        accountId: account.id,
        folder: MailFolder.trash,
        sender: const EmailAddress(
            name: 'Old Notification', email: 'old@service.example'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Old notification',
        preview: 'This message was moved to trash.',
        bodyPlainText: 'This message was moved to trash.',
        bodyHtml: '<p>This message was moved to trash.</p>',
        date: now.subtract(const Duration(days: 10)),
      ),
      EmailMessage(
        id: 'm14',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'Jordan Lee', email: 'jordan.lee@example.com'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        cc: const [
          EmailAddress(name: 'Sam Rivera', email: 'sam.rivera@example.com')
        ],
        subject: 'Meeting notes and action items',
        preview:
            'Here are the notes from today, with owners assigned for each action.',
        bodyPlainText:
            'Here are the notes from today, with owners assigned for each action.\n- Alex: review draft\n- Sam: update docs',
        bodyHtml: '''
<div style="font-family:Segoe UI,Arial,sans-serif;color:#1f2937;line-height:1.6">
  <p>Here are the notes from today, with owners assigned for each action.</p>
  <ul><li><strong>Alex:</strong> review draft</li><li><strong>Sam:</strong> update docs</li></ul>
</div>
''',
        date: now.subtract(const Duration(days: 1, hours: 9)),
        labels: const ['Work'],
      ),
      EmailMessage(
        id: 'm15',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender:
            const EmailAddress(name: 'HR Updates', email: 'hr@company.example'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Updated holiday schedule',
        preview: 'Please review the updated holiday schedule for next quarter.',
        bodyPlainText:
            'Please review the updated holiday schedule for next quarter.',
        bodyHtml:
            '<p>Please review the updated holiday schedule for next quarter.</p>',
        date: now.subtract(const Duration(days: 7)),
      ),
      EmailMessage(
        id: 'm16',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'Alex Rivera', email: 'alex.rivera@example.com'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Feedback on the new settings layout',
        preview:
            'The density options feel clear, but the privacy section could use a short explanation.',
        bodyPlainText:
            'The density options feel clear, but the privacy section could use a short explanation.',
        bodyHtml:
            '<p>The density options feel clear, but the privacy section could use a short explanation.</p>',
        date: now.subtract(const Duration(hours: 8)),
        isStarred: true,
      ),
      EmailMessage(
        id: 'm17',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender:
            const EmailAddress(name: 'Build Bot', email: 'ci@builds.example'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Nightly build succeeded',
        preview: 'All checks passed for main at 02:14 UTC.',
        bodyPlainText: 'All checks passed for main at 02:14 UTC.',
        bodyHtml:
            '<div style="font-family:Segoe UI,Arial,sans-serif"><p style="color:#1f8b4c"><strong>Success:</strong> All checks passed for <code>main</code> at 02:14 UTC.</p></div>',
        date: now.subtract(const Duration(days: 3, hours: 5)),
        labels: const ['Dev'],
      ),
      EmailMessage(
        id: 'm18',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'Casey Morgan', email: 'casey.morgan@example.com'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Dinner next week?',
        preview:
            'Are you free next Thursday evening? There is a new place downtown.',
        bodyPlainText:
            'Are you free next Thursday evening? There is a new place downtown.',
        bodyHtml:
            '<p>Are you free next Thursday evening? There is a new place downtown.</p>',
        date: now.subtract(const Duration(days: 5, hours: 2)),
        labels: const ['Personal'],
      ),
      EmailMessage(
        id: 'm19',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender:
            const EmailAddress(name: 'Docs Team', email: 'docs@example.com'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Documentation style guide update',
        preview:
            'We updated the writing style guide with new examples for error messages.',
        bodyPlainText:
            'We updated the writing style guide with new examples for error messages.',
        bodyHtml:
            '<p>We updated the writing style guide with new examples for error messages.</p><p>See attachment for details.</p>',
        date: now.subtract(const Duration(days: 8)),
        attachments: const [
          Attachment(
              id: 'a19',
              name: 'style-guide-notes.txt',
              type: AttachmentType.txt,
              sizeBytes: 4096,
              previewText:
                  'Kmail writing style guide notes\n- Be clear\n- Be calm\n- Be specific'),
        ],
      ),
      EmailMessage(
        id: 'm20',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender:
            const EmailAddress(name: 'Finance', email: 'finance@example.com'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Quarterly report attached',
        preview:
            'Please find the quarterly report attached. Let us know if you need CSV exports.',
        bodyPlainText:
            'Please find the quarterly report attached. Let us know if you need CSV exports.',
        bodyHtml:
            '<p>Please find the quarterly report attached. Let us know if you need CSV exports.</p>',
        date: now.subtract(const Duration(days: 11)),
        attachments: const [
          Attachment(
              id: 'a20a',
              name: 'quarterly-report.pdf',
              type: AttachmentType.pdf,
              sizeBytes: 3145728),
          Attachment(
              id: 'a20b',
              name: 'summary.csv',
              type: AttachmentType.csv,
              sizeBytes: 24576,
              previewText:
                  'Quarter,Revenue,Expenses\nQ1,120000,80000\nQ2,135000,86000'),
        ],
      ),
      EmailMessage(
        id: 'm21',
        accountId: account.id,
        folder: MailFolder.inbox,
        sender: const EmailAddress(
            name: 'Malformed HTML Test', email: 'qa@example.com'),
        to: const [
          EmailAddress(name: 'Alex Morgan', email: 'alex.morgan@kmail.app')
        ],
        subject: 'Malformed HTML rendering test',
        preview:
            'This message intentionally contains broken and suspicious HTML for testing.',
        bodyPlainText:
            'This message intentionally contains broken and suspicious HTML for testing. Safe content should still be visible.',
        bodyHtml: '''
<div><p>Safe content should still be visible.</p><img src="http://tracker.example/pixel.png" onerror="alert(1)"><script>alert('xss')</script><a href="javascript:alert('bad')">bad link</a><p>Broken <strong>markup''',
        date: now.subtract(const Duration(days: 12)),
        isUnread: false,
        hasRemoteImages: true,
        labels: const ['QA'],
      ),
    ];
  }
}
