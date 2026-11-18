import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: RealEstateApp(),
    ),
  );
}

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RealEstate Pro CRM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F4C81), // Classic Deep Trust Blue
          primary: const Color(0xFF0F4C81),
          secondary: const Color(0xFFE5A93C), // Warm Gold for Real Estate
        ),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const MainDashboardScreen(),
    );
  }
}

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    LeadsPipelinePlaceholder(),
    InventoryMasterPlaceholder(),
    CallLogsPlaceholder(),
    TimeMatrixPlaceholder(),
    SettingsPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitleForIndex(_currentIndex),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade700),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, size: 14, color: Colors.green.shade800),
                const SizedBox(width: 4),
                Text(
                  "Local Private",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Leads',
          ),
          NavigationDestination(
            icon: Icon(Icons.apartment_outlined),
            selectedIcon: Icon(Icons.apartment),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.phone_in_talk_outlined),
            selectedIcon: Icon(Icons.phone_in_talk),
            label: 'Calls & Overlay',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time_filled),
            label: 'Time Matrix',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  String _getTitleForIndex(int idx) {
    switch (idx) {
      case 0:
        return 'Sales Pipeline (Leads)';
      case 1:
        return 'Inventory & Sites Master';
      case 2:
        return 'Call Intelligence & Overlay';
      case 3:
        return 'Temporal Matrix (Velocity)';
      case 4:
        return 'Configuration & Sync';
      default:
        return 'RealEstate CRM';
    }
  }
}

class LeadsPipelinePlaceholder extends StatelessWidget {
  const LeadsPipelinePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStageCard(
          context,
          title: "New Leads",
          count: 3,
          color: Colors.blue,
          subtitle: "Newly captured from calls & WhatsApp",
        ),
        _buildStageCard(
          context,
          title: "Site Visit Scheduled",
          count: 2,
          color: Colors.amber,
          subtitle: "Upcoming physical visits this week",
        ),
        _buildStageCard(
          context,
          title: "Token / Biana Pending",
          count: 1,
          color: Colors.purple,
          subtitle: "Advances & legal document checks",
        ),
        _buildStageCard(
          context,
          title: "Deal Closed / Registry",
          count: 4,
          color: Colors.green,
          subtitle: "Successfully registered transactions",
        ),
      ],
    );
  }

  Widget _buildStageCard(
    BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            count.toString(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}

class InventoryMasterPlaceholder extends StatelessWidget {
  const InventoryMasterPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work_outlined, size: 64, color: Theme.of(context).primaryColor),
            const SizedBox(height: 16),
            const Text(
              "Inventory & Site Master",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Projects, Society Flats, Villas, Plots and Commercial Units with custom schemas will be listed here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CallLogsPlaceholder extends StatelessWidget {
  const CallLogsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: const Color(0xFFF0F7FF),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.layers, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      "Truecaller-Compatible Overlay",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  "App will listen to incoming/outgoing calls. When client calls, bottom dock shows past history & Hindi AI summary.",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text("Verify Overlay Permission"),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TimeMatrixPlaceholder extends StatelessWidget {
  const TimeMatrixPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Micro Velocity & Time Matrices Module"),
    );
  }
}

class SettingsPlaceholder extends StatelessWidget {
  const SettingsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          title: const Text("100% Local-Only Mode"),
          subtitle: const Text("Keep all recordings and leads exclusively on this device"),
          value: true,
          onChanged: (val) {},
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.translate),
          title: const Text("Real Estate Hindi Keywords"),
          subtitle: const Text("Review & inject custom Hindi terms (बयाना, टोकन, आदि)"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}
