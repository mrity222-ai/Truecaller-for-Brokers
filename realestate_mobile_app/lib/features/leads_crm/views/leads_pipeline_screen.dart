import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models/lead_entity.dart';
import '../../../core/database/models/sales_stage_entity.dart';
import '../../call_manager/views/post_call_review_dialog.dart';
import 'add_edit_lead_dialog.dart';

class LeadsPipelineScreen extends StatefulWidget {
  const LeadsPipelineScreen({super.key});

  @override
  State<LeadsPipelineScreen> createState() => _LeadsPipelineScreenState();
}

class _LeadsPipelineScreenState extends State<LeadsPipelineScreen> {
  String _selectedStageId = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppDatabase.instance.init().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<LeadEntity> _getFilteredLeads() {
    var leads = AppDatabase.instance.getLeadsByStage(_selectedStageId);
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      leads = leads.where((l) =>
        l.name.toLowerCase().contains(q) ||
        l.phoneNumber.contains(q) ||
        l.preferredLocation.toLowerCase().contains(q)
      ).toList();
    }
    return leads;
  }

  String _formatBudget(double budget) {
    if (budget >= 10000000) {
      return '₹${(budget / 10000000).toStringAsFixed(2)} Cr';
    } else {
      return '₹${(budget / 100000).toStringAsFixed(0)} Lakh';
    }
  }

  @override
  Widget build(BuildContext context) {
    final stages = AppDatabase.instance.getAllStages();
    final leads = _getFilteredLeads();

    return Scaffold(
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by client name, phone or location...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Stage Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _buildStageFilterChip('all', 'All Clients', AppDatabase.instance.getAllLeads().length, Colors.blueGrey),
                ...stages.map((stage) {
                  final count = AppDatabase.instance.getLeadsByStage(stage.id).length;
                  return _buildStageFilterChip(stage.id, stage.stageName, count, Color(stage.colorHex));
                }),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Leads List
          Expanded(
            child: leads.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No clients found in this stage',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: leads.length,
                    itemBuilder: (ctx, index) {
                      final lead = leads[index];
                      return _buildLeadCard(lead);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          AddEditLeadDialog.show(context, onSaved: () {
            setState(() {});
          });
        },
        backgroundColor: const Color(0xFF0F4C81),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Client', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStageFilterChip(String stageId, String label, int count, Color color) {
    final isSelected = _selectedStageId == stageId;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : color.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        onSelected: (_) => setState(() => _selectedStageId = stageId),
      ),
    );
  }

  Widget _buildLeadCard(LeadEntity lead) {
    final stage = AppDatabase.instance.getStageById(lead.currentStageId);
    final stageColor = Color(stage?.colorHex ?? 0xFF1E88E5);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: lead.isCold ? BorderSide(color: Colors.red.shade300, width: 1.5) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name + Stage Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    lead.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: stageColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: stageColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    stage?.stageName ?? 'Lead',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: stageColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Requirements & Budget
            Row(
              children: [
                Text(
                  _formatBudget(lead.budgetInr),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F4C81)),
                ),
                const SizedBox(width: 8),
                Text('•', style: TextStyle(color: Colors.grey.shade400)),
                const SizedBox(width: 8),
                Text(
                  '${lead.inventoryType} in ${lead.preferredLocation}',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Deal Health & Inactivity Alert
            Row(
              children: [
                Icon(
                  lead.isCold ? Icons.warning_amber_rounded : Icons.access_time,
                  size: 14,
                  color: lead.isCold ? Colors.red.shade700 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  lead.isCold
                      ? 'Cold Warning: No contact in ${lead.daysSinceContact} days'
                      : 'Last contact: ${lead.daysSinceContact == 0 ? "Today" : "${lead.daysSinceContact}d ago"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: lead.isCold ? FontWeight.bold : FontWeight.normal,
                    color: lead.isCold ? Colors.red.shade700 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            // Custom Dynamic Fields Preview
            if (lead.customFieldsData.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: lead.customFieldsData.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      '${e.key}: ${e.value}',
                      style: const TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    PostCallReviewDialog.show(
                      context,
                      phoneNumber: lead.phoneNumber,
                      initialName: lead.name,
                      suggestedSummary: 'Follow-up regarding ${lead.inventoryType} requirements.',
                      suggestedActionable: 'Call to confirm next appointment.',
                      onSaved: () => setState(() {}),
                    );
                  },
                  icon: const Icon(Icons.note_alt_outlined, size: 16),
                  label: const Text('Add Note', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    AddEditLeadDialog.show(
                      context,
                      lead: lead,
                      onSaved: () => setState(() {}),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
