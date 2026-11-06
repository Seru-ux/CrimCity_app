// lib/screens/underworld_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'crew_dashboard_screen.dart';
import 'docs_screen.dart';
import 'gang_screen.dart';

class UnderworldScreen extends StatefulWidget {
  const UnderworldScreen({super.key});

  @override
  State<UnderworldScreen> createState() => _UnderworldScreenState();
}

class _UnderworldScreenState extends State<UnderworldScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: const Color(0xFF141414),
          child: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFE11D48),
            indicatorWeight: 2,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFFA3A3A3),
            labelStyle: GoogleFonts.oswald(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
            unselectedLabelStyle: GoogleFonts.oswald(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
            tabs: const [
              Tab(icon: Icon(Icons.groups, size: 18), text: 'CREW'),
              Tab(icon: Icon(Icons.shield, size: 18), text: 'GANG'),
              Tab(icon: Icon(Icons.description, size: 18), text: 'DOCS'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              CrewDashboardScreen(embedded: true),
              GangScreen(embedded: true),
              DocsScreen(),
            ],
          ),
        ),
      ],
    );
  }
}