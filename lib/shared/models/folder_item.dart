import 'package:flutter/material.dart';
import 'package:kmail_desktop/shared/models/mail_models.dart';

class FolderItem {
  const FolderItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.view,
    this.count = 0,
  });

  final String id;
  final String label;
  final IconData icon;
  final MailboxView view;
  final int count;
}
