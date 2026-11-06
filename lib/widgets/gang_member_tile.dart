// lib/widgets/gang_member_tile.dart
import 'package:flutter/material.dart';

import '../models/gang.dart';
import '../models/gang_member.dart';

class GangMemberTile extends StatelessWidget {
  final GangMember member;
  final VoidCallback? onKick;

  const GangMemberTile({super.key, required this.member, this.onKick});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Text(member.player.username[0].toUpperCase()),
      ),
      title: Text(
        member.player.username,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        member.role.name.toUpperCase(),
        style: const TextStyle(color: Colors.white54),
      ),
      trailing: member.role == GangRole.leader
          ? const Icon(Icons.star, color: Colors.amber)
          : onKick != null
          ? IconButton(
              icon: const Icon(Icons.person_remove, color: Colors.red),
              onPressed: onKick,
            )
          : null,
    );
  }
}
