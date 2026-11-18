import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/app_database.dart';
import 'core/native_bridge/call_overlay_bridge.dart';
import 'features/leads_crm/views/leads_pipeline_screen.dart';
import 'features/call_manager/views/post_call_review_dialog.dart';
import 'features/on_device_ai/keyword_management/custom_keywords_screen.dart';
import 'features/on_device_ai/views/ai_simulator_screen.dart';
import 'features/inventory_master/views/inventory_list_screen.dart';
import 'features/time_matrix_analytics/views/time_matrix_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.instance.init();
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
    LeadsPipelineScreen(),
    InventoryListScreen(),
    CallLogsPlaceholder(),
    TimeMatrixScreen(),
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

class CallLogsPlaceholder extends StatefulWidget {
  const CallLogsPlaceholder({super.key});

  @override
  State<CallLogsPlaceholder> createState() => _CallLogsPlaceholderState();
}

class _CallLogsPlaceholderState extends State<CallLogsPlaceholder> {
  bool _hasOverlayPermission = false;
  String _permissionStatus = "Not checked";

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPerm = await CallOverlayBridge.checkOverlayPermission();
    if (mounted) {
      setState(() {
        _hasOverlayPermission = hasPerm;
        _permissionStatus = hasPerm ? "Granted (Active)" : "Required (Action needed)";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
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
                  "App listens to incoming/outgoing calls. When client calls, bottom dock shows past history & Hindi AI summary.",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      _hasOverlayPermission ? Icons.check_circle : Icons.warning_amber,
                      color: _hasOverlayPermission ? Colors.green : Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Overlay Permission: $_permissionStatus",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _hasOverlayPermission ? Colors.green.shade800 : Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await CallOverlayBridge.requestOverlayPermission();
                        await _checkPermission();
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text("Request Permission"),
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        await CallOverlayBridge.showFloatingOverlay(
                          clientName: "Rahul Verma (Buyer)",
                          clientStage: "Site Visit (3BHK)",
                          lastSummary: "Budget 85L in Noida Sec 137. Wife preferred park facing. SBI loan approved.",
                          icebreaker: "Confirm if Saturday 4 PM site visit suits him.",
                          phoneNumber: "+91 98765 43210",
                        );
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text("Test Live Floating Card"),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await CallOverlayBridge.hideFloatingOverlay();
                      },
                      icon: const Icon(Icons.close),
                      label: const Text("Hide Card"),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        PostCallReviewDialog.show(
                          context,
                          phoneNumber: "+91 98765 43210",
                          initialName: "Rahul Verma",
                          suggestedSummary: "क्लाइंट को 85 लाख तक में सेक्टर 137 में 3BHK रेडी टू मूव चाहिए। शनिवार 4 बजे साइट विजिट फिक्स हुई है।",
                          suggestedActionable: "शनिवार 4 बजे पारस टिएरा 3BHK फ्लैट विजिट कराना है।",
                        );
                      },
                      icon: const Icon(Icons.call_end),
                      label: const Text("Test Post-Call Dialog"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F7FF),
                        foregroundColor: const Color(0xFF0F4C81),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AISimulatorScreen()),
                        );
                      },
                      icon: const Icon(Icons.record_voice_over),
                      label: const Text("Open AI Speech & NLP Simulator"),
                    ),
                  ],
                ),
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
          leading: const Icon(Icons.translate, color: Color(0xFF0F4C81)),
          title: const Text("Real Estate Hindi Keywords"),
          subtitle: const Text("Review & inject custom Hindi terms (बयाना, टोकन, आदि)"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomKeywordsScreen()),
            );
          },
        ),
      ],
    );
  }
}
