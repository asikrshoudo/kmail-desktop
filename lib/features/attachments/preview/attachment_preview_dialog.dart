import 'package:flutter/material.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/attachments/preview/attachment_preview_service.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class AttachmentPreviewDialog extends StatelessWidget {
  const AttachmentPreviewDialog({super.key, required this.attachment});
  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        width: 920,
        height: 680,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(attachment.name, style: Theme.of(context).textTheme.titleLarge),
                        Text('Preview is read-only in Phase 1 mock foundation', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                  IconButton(tooltip: 'Close', onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: Padding(padding: const EdgeInsets.all(AppSpacing.md), child: AttachmentPreviewService.preview(attachment))),
          ],
        ),
      ),
    );
  }
}
