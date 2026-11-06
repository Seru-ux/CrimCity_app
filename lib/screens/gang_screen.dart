// lib/screens/gang_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/gang_controller.dart';
import '../models/gang.dart';
import 'gang_browser_screen.dart';
import 'gang_create_screen.dart';
import 'gang_invite_screen.dart';

class GangScreen extends ConsumerStatefulWidget {
  /// Wenn true, wird KEIN eigener Scaffold/AppBar gezeichnet
  /// (für Einbettung in UnderworldScreen).
  final bool embedded;

  const GangScreen({super.key, this.embedded = false});

  @override
  ConsumerState<GangScreen> createState() => _GangScreenState();
}

class _GangScreenState extends ConsumerState<GangScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(gangControllerProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gangControllerProvider);

    // Body je nach Status
    final Widget body = switch (state.status) {
      GangStatus.loading => const Center(
        child: CircularProgressIndicator(color: Color(0xFFB00020)),
      ),
      GangStatus.noGang => _NoGangView(state: state),
      GangStatus.inGang => _InGangView(state: state),
      GangStatus.error => Center(
        child: Text(
          state.error ?? 'Fehler',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      _ => const Center(
        child: Text(
          'Unbekannter Status',
          style: TextStyle(color: Colors.white),
        ),
      ),
    };

    // Embedded: nur Body, kein Scaffold
    if (widget.embedded) {
      return Container(color: const Color(0xFF0A0A0A), child: body);
    }

    // Standalone: mit Scaffold + AppBar wie bisher
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(
          'GANG',
          style: GoogleFonts.oswald(
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (state.status == GangStatus.inGang)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFB00020)),
              onPressed: () => ref.read(gangControllerProvider.notifier).load(),
            ),
        ],
      ),
      body: body,
    );
  }
}

// ============================================================
// AB HIER: UNVERÄNDERT (alles was du hattest)
// ============================================================

class _NoGangView extends ConsumerWidget {
  final GangState state;

  const _NoGangView({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups, size: 100, color: Color(0xFFB00020)),
          const SizedBox(height: 24),
          Text(
            'DU BIST EIN EINSAMER WOLF',
            style: GoogleFonts.oswald(
              fontSize: 22,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Schließe dich einer Gang an oder gründe dein eigenes Imperium.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB00020),
              minimumSize: const Size.fromHeight(56),
              elevation: 5,
              shadowColor: const Color(0xFFB00020).withOpacity(0.5),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GangCreateScreen()),
            ),
            child: Text(
              'GANG GRÜNDEN (50.000 \$)',
              style: GoogleFonts.oswald(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              side: const BorderSide(color: Color(0xFFB00020), width: 2),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GangBrowserScreen()),
            ),
            child: Text(
              'GANGS DURCHSUCHEN',
              style: GoogleFonts.oswald(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _InGangView extends ConsumerStatefulWidget {
  final GangState state;

  const _InGangView({required this.state});

  @override
  ConsumerState<_InGangView> createState() => _InGangViewState();
}

class _InGangViewState extends ConsumerState<_InGangView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => ref.read(gangControllerProvider.notifier).loadApplications(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gang = widget.state.gang!;
    final myRole = widget.state.myRole;
    final isLeader = myRole == GangRole.leader;
    final canManage = isLeader || myRole == GangRole.officer;

    return DefaultTabController(
      length: canManage ? 5 : 4,
      child: Column(
        children: [
          // --- HEADER ---
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF111111),
              border: Border(
                bottom: BorderSide(color: Color(0xFFB00020), width: 2),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFB00020),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '[${gang.tag}]',
                    style: GoogleFonts.oswald(
                      fontSize: 20,
                      color: const Color(0xFFB00020),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gang.name.toUpperCase(),
                        style: GoogleFonts.oswald(
                          fontSize: 22,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'LEVEL ${gang.level} · ${widget.state.memberCount}/${gang.memberSlots} SLOTS',
                        style: GoogleFonts.robotoMono(
                          fontSize: 10,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.blueAccent.withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.blueAccent,
                        size: 16,
                      ),
                      Text(
                        '${gang.influence}',
                        style: GoogleFonts.oswald(
                          color: Colors.blueAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // --- EXP BAR ---
          Container(
            color: const Color(0xFF0A0A0A),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GANG EXP',
                      style: GoogleFonts.oswald(
                        fontSize: 12,
                        color: Colors.white54,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${gang.xp} / ${(gang.level * 500)}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 10,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: (gang.xp % 500) / 500,
                    backgroundColor: const Color(0xFF1A1A1A),
                    color: Colors.amber,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          // --- TABS ---
          Container(
            color: Colors.black,
            child: TabBar(
              isScrollable: true,
              indicatorColor: const Color(0xFFB00020),
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white30,
              labelStyle: GoogleFonts.oswald(fontSize: 14, letterSpacing: 1),
              tabs: [
                const Tab(text: 'CREW'),
                const Tab(text: 'MISSIONEN'),
                const Tab(text: 'TERRITORIUM'),
                if (canManage) const Tab(text: 'BEWERBUNGEN'),
                const Tab(text: 'SYSTEM'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: widget.state.members.length,
                  itemBuilder: (_, i) {
                    final m = widget.state.members[i];
                    final isMe =
                        m.playerId ==
                            Supabase.instance.client.auth.currentUser?.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141414),
                        border: Border(
                          left: BorderSide(
                            color: m.role == GangRole.leader
                                ? Colors.amber
                                : const Color(0xFFB00020),
                            width: 3,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF1A1A1A),
                          child: Text(
                            m.player.username[0].toUpperCase(),
                            style: TextStyle(
                              color: m.role == GangRole.leader
                                  ? Colors.amber
                                  : Colors.white,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              m.player.username.toUpperCase(),
                              style: GoogleFonts.oswald(color: Colors.white),
                            ),
                            if (isMe) ...[
                              const SizedBox(width: 8),
                              const Text(
                                '(DU)',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          m.role.name.toUpperCase(),
                          style: TextStyle(
                            color: m.role == GangRole.leader
                                ? Colors.amber
                                : (m.role == GangRole.officer
                                ? Colors.blueAccent
                                : Colors.white54),
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        trailing: isLeader && m.role != GangRole.leader
                            ? PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white54,
                          ),
                          color: const Color(0xFF1A1A1A),
                          onSelected: (value) {
                            if (value == 'promote') {
                              ref
                                  .read(gangControllerProvider.notifier)
                                  .changeMemberRole(
                                m.playerId,
                                GangRole.officer,
                              );
                            }
                            if (value == 'demote') {
                              ref
                                  .read(gangControllerProvider.notifier)
                                  .changeMemberRole(
                                m.playerId,
                                GangRole.member,
                              );
                            }
                            if (value == 'kick') {
                              ref
                                  .read(gangControllerProvider.notifier)
                                  .kickMember(m.playerId);
                            }
                          },
                          itemBuilder: (context) => [
                            if (m.role == GangRole.member)
                              const PopupMenuItem(
                                value: 'promote',
                                child: Text(
                                  'Befördern',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            if (m.role == GangRole.officer)
                              const PopupMenuItem(
                                value: 'demote',
                                child: Text(
                                  'Degradieren',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'kick',
                              child: Text(
                                'Rauswerfen',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        )
                            : null,
                      ),
                    );
                  },
                ),
                _MissionsTab(state: widget.state, canManage: canManage),
                _DistrictsTab(state: widget.state, canManage: canManage),
                if (canManage)
                  widget.state.applications.isEmpty
                      ? const Center(
                    child: Text(
                      'Keine Bewerbungen.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: widget.state.applications.length,
                    itemBuilder: (_, i) {
                      final app = widget.state.applications[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF1A1A1A),
                            child: Icon(
                              Icons.person,
                              color: Colors.white54,
                            ),
                          ),
                          title: Text(
                            app.applicantName.toUpperCase(),
                            style: GoogleFonts.oswald(
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            app.message.isEmpty
                                ? 'Möchte beitreten.'
                                : app.message,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () => ref
                                    .read(gangControllerProvider.notifier)
                                    .respondToApplication(app.id, true),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () => ref
                                    .read(gangControllerProvider.notifier)
                                    .respondToApplication(app.id, false),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ListView(
                  children: [
                    if (isLeader) ...[
                      ListTile(
                        leading: const Icon(
                          Icons.settings,
                          color: Colors.amber,
                        ),
                        title: Text(
                          'GANG-EINSTELLUNGEN',
                          style: GoogleFonts.oswald(color: Colors.white),
                        ),
                        subtitle: Text(
                          gang.isRecruiting
                              ? 'Rekrutierung: Offen'
                              : 'Rekrutierung: Geschlossen',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        onTap: () =>
                            _showGangSettingsDialog(context, ref, gang),
                      ),
                      const Divider(color: Colors.white10),
                    ],
                    if (canManage)
                      ListTile(
                        leading: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                        ),
                        title: Text(
                          'SPIELER EINLADEN',
                          style: GoogleFonts.oswald(color: Colors.white),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GangInviteScreen(),
                          ),
                        ),
                      ),
                    ListTile(
                      leading: const Icon(Icons.exit_to_app, color: Colors.red),
                      title: Text(
                        'GANG VERLASSEN',
                        style: GoogleFonts.oswald(color: Colors.red),
                      ),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF1A1A1A),
                            title: const Text(
                              'Gang verlassen?',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'Bist du sicher?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Abbrechen'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Verlassen',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(gangControllerProvider.notifier)
                              .leaveGang();
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showGangSettingsDialog(BuildContext context, WidgetRef ref, Gang gang) {
    final descCtrl = TextEditingController(text: gang.description);
    bool isRecruiting = gang.isRecruiting;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Gang-Einstellungen',
              style: GoogleFonts.oswald(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descCtrl,
                  maxLength: 200,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Beschreibung',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                SwitchListTile(
                  title: const Text(
                    'Rekrutierung offen',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    'Andere Spieler können sich bewerben',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  value: isRecruiting,
                  activeColor: const Color(0xFFB00020),
                  onChanged: (val) => setState(() => isRecruiting = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Abbrechen'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB00020),
                ),
                onPressed: () {
                  ref
                      .read(gangControllerProvider.notifier)
                      .updateGangSettings(
                    description: descCtrl.text.trim(),
                    isRecruiting: isRecruiting,
                  );
                  Navigator.pop(ctx);
                },
                child: const Text('Speichern'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DistrictsTab extends ConsumerWidget {
  final GangState state;
  final bool canManage;

  const _DistrictsTab({required this.state, required this.canManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.districts.isEmpty) {
      return const Center(
        child: Text(
          'Satellitendaten werden geladen...',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.districts.length,
      itemBuilder: (_, i) {
        final d = state.districts[i];
        final isMine = d.gangId == state.gang?.id;
        final isEnemy = d.gangId != null && !isMine;

        Color cardColor = const Color(0xFF141414);
        Color borderColor = Colors.white12;
        Color iconColor = Colors.white54;
        IconData iconData = Icons.lock_open;

        if (isMine) {
          cardColor = const Color(0xFF0F1A12);
          borderColor = Colors.green.withOpacity(0.5);
          iconColor = Colors.green;
          iconData = Icons.shield;
        } else if (isEnemy) {
          cardColor = const Color(0xFF1A0F0F);
          borderColor = const Color(0xFFB00020).withOpacity(0.5);
          iconColor = const Color(0xFFB00020);
          iconData = Icons.warning_amber_rounded;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isMine
                ? [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 10,
              ),
            ]
                : [],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(iconData, color: iconColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d.name.toUpperCase(),
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            isMine
                                ? 'UNTER KONTROLLE'
                                : (isEnemy ? 'FEINDLICHES GEBIET' : 'NEUTRAL'),
                            style: GoogleFonts.robotoMono(
                              fontSize: 10,
                              color: isMine
                                  ? Colors.green
                                  : (isEnemy
                                  ? const Color(0xFFB00020)
                                  : Colors.white54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  d.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.attach_money,
                            color: Colors.amber,
                            size: 16,
                          ),
                          Text(
                            '${d.incomeMoney} / h',
                            style: GoogleFonts.robotoMono(
                              color: Colors.amber,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                          Text(
                            '${d.incomeInfluence} / h',
                            style: GoogleFonts.robotoMono(
                              color: Colors.blueAccent,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (isMine)
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        side: BorderSide(color: Colors.green.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () => ref
                          .read(gangControllerProvider.notifier)
                          .collectIncome(d.id),
                      icon: const Icon(
                        Icons.monetization_on,
                        color: Colors.green,
                        size: 18,
                      ),
                      label: Text(
                        'EINKOMMEN EINSAMMELN',
                        style: GoogleFonts.oswald(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else if (d.isNeutral)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB00020),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: canManage
                          ? () => ref
                          .read(gangControllerProvider.notifier)
                          .claimDistrict(d.id)
                          : null,
                      child: Text(
                        'BEANSPRUCHEN (${d.requiredInfluence} EINFLUSS)',
                        style: GoogleFonts.oswald(fontSize: 14),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFB00020)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Angriffe kommen in Phase 3.2!'),
                          ),
                        );
                      },
                      child: Text(
                        'ANGREIFEN (BALD)',
                        style: GoogleFonts.oswald(
                          color: const Color(0xFFB00020),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MissionsTab extends ConsumerWidget {
  final GangState state;
  final bool canManage;

  const _MissionsTab({required this.state, required this.canManage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 60, color: Colors.white12),
            const SizedBox(height: 16),
            Text(
              'KEINE AKTIVEN MISSIONEN',
              style: GoogleFonts.oswald(
                color: Colors.white54,
                letterSpacing: 2,
              ),
            ),
            if (canManage) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB00020),
                ),
                onPressed: () => _showStartMissionDialog(context, ref),
                child: Text('MISSION STARTEN', style: GoogleFonts.oswald()),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: state.missions.length,
      itemBuilder: (_, i) {
        final mission = state.missions[i];
        final isCompleted = mission.status == 'completed';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            border: Border.all(
              color: isCompleted
                  ? Colors.green.withOpacity(0.3)
                  : Colors.white12,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle : Icons.assignment,
                      color: isCompleted
                          ? Colors.green
                          : const Color(0xFFB00020),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mission.name.toUpperCase(),
                        style: GoogleFonts.oswald(
                          fontSize: 18,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    Text(
                      '+${mission.expReward} EXP',
                      style: GoogleFonts.robotoMono(
                        color: Colors.amber,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  mission.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mission.progress,
                    backgroundColor: Colors.black,
                    color: isCompleted ? Colors.green : const Color(0xFFB00020),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${mission.currentContributions} / ${mission.requiredContributions}',
                      style: GoogleFonts.robotoMono(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    if (!isCompleted)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB00020),
                          minimumSize: const Size(100, 36),
                        ),
                        onPressed: () => ref
                            .read(gangControllerProvider.notifier)
                            .contributeToMission(mission.id, 1),
                        child: Text(
                          'HELFEN (+1)',
                          style: GoogleFonts.oswald(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStartMissionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Mission starten',
          style: GoogleFonts.oswald(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Bankraub',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Sammle 10 Beiträge. +500 EXP.',
                style: TextStyle(color: Colors.white54),
              ),
              onTap: () {
                ref
                    .read(gangControllerProvider.notifier)
                    .startMission(
                  missionCode: 'bank_job',
                  name: 'Bankraub',
                  description: 'Bereite den großen Coup vor.',
                  requiredContributions: 10,
                  expReward: 500,
                );
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text(
                'Patrouille',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Sammle 5 Beiträge. +200 EXP.',
                style: TextStyle(color: Colors.white54),
              ),
              onTap: () {
                ref
                    .read(gangControllerProvider.notifier)
                    .startMission(
                  missionCode: 'patrol',
                  name: 'Patrouille',
                  description: 'Sichere das Revier.',
                  requiredContributions: 5,
                  expReward: 200,
                );
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}