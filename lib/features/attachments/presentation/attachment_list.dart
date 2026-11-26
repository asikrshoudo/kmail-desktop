import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:kmail_desktop/design_system/tokens/app_colors.dart';
import 'package:kmail_desktop/design_system/tokens/app_radii.dart';
import 'package:kmail_desktop/design_system/tokens/app_spacing.dart';
import 'package:kmail_desktop/features/attachments/preview/attachment_preview_dialog.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';
import 'package:path/path.dart' as p;

class AttachmentList extends StatelessWidget {
  const AttachmentList({super.key, required this.attachments});
  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [for (final a in attachments) _AttachmentCard(attachment: a)],
    );
  }
}

class _AttachmentCard extends StatelessWidget {
  const _AttachmentCard({required this.attachment});
  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors.tokens;
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconFor(attachment.type), color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(attachment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              '${attachment.extension.toUpperCase()} • ${_formatBytes(attachment.sizeBytes)}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton(
                onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) =>
                        AttachmentPreviewDialog(attachment: attachment)),
                child: const Text('Preview'),
              ),
              const SizedBox(width: 8),
              TextButton(
                  onPressed: () => _save(context), child: const Text('Save')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final bytes = attachment.bytes;
    final text = attachment.previewText;
    if (bytes == null && text == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('This attachment is not available for local save yet.')));
      return;
    }
    final ext =
        attachment.extension.isNotEmpty ? '.${attachment.extension}' : null;
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save attachment',
      fileName: attachment.name,
      type: ext != null ? FileType.custom : FileType.any,
      allowedExtensions: ext != null ? [attachment.extension] : null,
    );
    if (savePath == null) return;
    final target = File(savePath);
    if (bytes != null) {
      await target.writeAsBytes(bytes, flush: true);
    } else {
      await target.writeAsString(text!, flush: true);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved to ${p.basename(target.path)}')));
    }
  }

  IconData _iconFor(AttachmentType type) {
    switch (type) {
      case AttachmentType.pdf:
        return Icons.picture_as_pdf_outlined;
      case AttachmentType.png:
      case AttachmentType.jpg:
      case AttachmentType.gif:
      case AttachmentType.webp:
        return Icons.image_outlined;
      case AttachmentType.txt:
      case AttachmentType.csv:
        return Icons.description_outlined;
      case AttachmentType.docx:
      case AttachmentType.xlsx:
        return Icons.insert_drive_file_outlined;
      case AttachmentType.zip:
        return Icons.folder_zip_outlined;
      case AttachmentType.html:
        return Icons.code_outlined;
      case AttachmentType.unknown:
        return Icons.attach_file_outlined;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}
