import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models/sales_stage_entity.dart';

class PostCallReviewDialog extends StatefulWidget {
  final String phoneNumber;
  final String initialName;
  final String suggestedSummary;
  final String suggestedActionable;
  final VoidCallback? onSaved;

  const PostCallReviewDialog({
    super.key,
    required this.phoneNumber,
    this.initialName = '',
    this.suggestedSummary = '',
    this.suggestedActionable = '',
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String phoneNumber,
    String initialName = '',
    String suggestedSummary = '',
    String suggestedActionable = '',
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PostCallReviewDialog(
        phoneNumber: phoneNumber,
        initialName: initialName,
        suggestedSummary: suggestedSummary,
        suggestedActionable: suggestedActionable,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<PostCallReviewDialog> createState() => _PostCallReviewDialogState();
}

class _PostCallReviewDialogState extends State<PostCallReviewDialog> {
  late TextEditingController _nameController;
  late TextEditingController _summaryController;
  late TextEditingController _actionController;
  late TextEditingController _budgetController;
  late TextEditingController _locationController;

  String _selectedStageId = 'site_visit_scheduled';
  String _selectedInventoryType = '3BHK';
  DateTime? _selectedFollowUpDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _summaryController = TextEditingController(text: widget.suggestedSummary);
    _actionController = TextEditingController(text: widget.suggestedActionable);
    _budgetController = TextEditingController(text: '85'); // in Lakhs default
    _locationController = TextEditingController(text: 'Noida Sec 137');
    _selectedFollowUpDate = DateTime.now().add(const Duration(days: 2));

    // Try finding existing client data
    final existing = AppDatabase.instance.getLeadByPhone(widget.phoneNumber);
    if (existing != null) {
      _nameController.text = existing.name;
      _selectedStageId = existing.currentStageId;
      _budgetController.text = (existing.budgetInr / 100000).toStringAsFixed(0);
      _locationController.text = existing.preferredLocation;
      _selectedInventoryType = existing.inventoryType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _summaryController.dispose();
    _actionController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    final budgetLakhs = double.tryParse(_budgetController.text.trim()) ?? 75.0;
    final budgetInr = budgetLakhs * 100000;

    await AppDatabase.instance.saveInteractionAndLead(
      phoneNumber: widget.phoneNumber,
      name: _nameController.text.trim(),
      stageId: _selectedStageId,
      budgetInr: budgetInr,
      location: _locationController.text.trim(),
      inventoryType: _selectedInventoryType,
      hindiSummary: _summaryController.text.trim(),
      actionItem: _actionController.text.trim(),
      followUpDate: _selectedFollowUpDate,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Client ${widget.phoneNumber} notes saved to local CRM!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stages = AppDatabase.instance.getAllStages();

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F4C81).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.call_end, color: Color(0xFF0F4C81)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Post-Call Quick Update',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.phoneNumber,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 24),

            // Client Name & Stage Selector
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Client Name',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedStageId,
                    decoration: const InputDecoration(
                      labelText: 'Stage',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: stages
                        .map((s) => DropdownMenuItem(value: s.id, child: Text(s.stageName, style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedStageId = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Budget & Location & Unit Type
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Budget (Lakhs)',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedInventoryType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: '2BHK', child: Text('2BHK')),
                      DropdownMenuItem(value: '3BHK', child: Text('3BHK')),
                      DropdownMenuItem(value: 'Villa', child: Text('Villa')),
                      DropdownMenuItem(value: 'Plot', child: Text('Plot')),
                      DropdownMenuItem(value: 'Shop', child: Text('Shop')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedInventoryType = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Hindi Summary (From On-Device AI)
            TextField(
              controller: _summaryController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Conversation Summary (Hindi / English)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),

            // Actionable Item
            TextField(
              controller: _actionController,
              decoration: const InputDecoration(
                labelText: 'Next Actionable / Task',
                prefixIcon: Icon(Icons.check_circle_outline, size: 20),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // Next Follow-up Reminder Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notification_add, color: Color(0xFF0F4C81)),
              title: const Text('Next Call / Follow-up Reminder', style: TextStyle(fontSize: 14)),
              subtitle: Text(
                _selectedFollowUpDate != null
                    ? DateFormat('EEEE, dd MMM yyyy').format(_selectedFollowUpDate!)
                    : 'No reminder set',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedFollowUpDate ?? DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 180)),
                  );
                  if (picked != null) {
                    setState(() => _selectedFollowUpDate = picked);
                  }
                },
                child: const Text('Change'),
              ),
            ),
            const SizedBox(height: 16),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _handleSave,
                icon: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save to Local CRM'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
