// lib/widgets/gang_invite_tile.dart
import 'package:flutter/material.dart';

import '../models/gang_invite.dart';

class GangInviteTile extends StatelessWidget {
  final GangInvite invite;
  final void Function(bool accept) onRespond;

  const GangInviteTile({
    super.key,
    required this.invite,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '[${invite.gangTag}] ${invite.gangName}',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: const Text(
        'Einladung zur Gang',
        style: TextStyle(color: Colors.white54),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => onRespond(true),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => onRespond(false),
          ),
        ],
      ),
    );
  }
}
