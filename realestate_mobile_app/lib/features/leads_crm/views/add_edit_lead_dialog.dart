import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models/lead_entity.dart';
import '../dynamic_schema/field_definition.dart';
import '../dynamic_schema/dynamic_form_widget.dart';

class AddEditLeadDialog extends StatefulWidget {
  final LeadEntity? lead;
  final VoidCallback? onSaved;

  const AddEditLeadDialog({super.key, this.lead, this.onSaved});

  static Future<void> show(BuildContext context, {LeadEntity? lead, VoidCallback? onSaved}) {
    return showDialog(
      context: context,
      builder: (ctx) => AddEditLeadDialog(lead: lead, onSaved: onSaved),
    );
  }

  @override
  State<AddEditLeadDialog> createState() => _AddEditLeadDialogState();
}

class _AddEditLeadDialogState extends State<AddEditLeadDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _budgetController;
  late TextEditingController _locationController;

  String _selectedStageId = 'new_lead';
  String _selectedInventoryType = '2BHK';
  Map<String, dynamic> _customFieldsData = {};
  List<FieldDefinition> _dynamicFields = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lead?.name ?? '');
    _phoneController = TextEditingController(text: widget.lead?.phoneNumber ?? '');
    _budgetController = TextEditingController(
      text: widget.lead != null ? (widget.lead!.budgetInr / 100000).toStringAsFixed(0) : '75',
    );
    _locationController = TextEditingController(text: widget.lead?.preferredLocation ?? 'Noida');
    _selectedStageId = widget.lead?.currentStageId ?? 'new_lead';
    _selectedInventoryType = widget.lead?.inventoryType ?? '2BHK';
    _customFieldsData = Map<String, dynamic>.from(widget.lead?.customFieldsData ?? {});

    _dynamicFields = List.from(FieldDefinition.defaultRealEstateFields);

    // If existing lead has extra custom fields not in default list, inject them
    _customFieldsData.forEach((k, v) {
      if (!_dynamicFields.any((f) => f.key == k)) {
        _dynamicFields.add(FieldDefinition(
          key: k,
          label: k[0].toUpperCase() + k.substring(1),
          type: FieldType.text,
        ));
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final budgetLakhs = double.tryParse(_budgetController.text.trim()) ?? 75.0;

    final lead = LeadEntity(
      id: widget.lead?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      currentStageId: _selectedStageId,
      budgetInr: budgetLakhs * 100000,
      preferredLocation: _locationController.text.trim(),
      inventoryType: _selectedInventoryType,
      customFieldsData: _customFieldsData,
      isClient: true,
      lastContactedAt: widget.lead?.lastContactedAt ?? now,
      createdAt: widget.lead?.createdAt ?? now,
      updatedAt: now,
    );

    await AppDatabase.instance.saveLead(lead);

    if (mounted) {
      Navigator.pop(context);
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stages = AppDatabase.instance.getAllStages();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.lead == null ? 'Add New Client' : 'Edit Client Profile',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Client Name *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Phone number is required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Stage & Inventory Type
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStageId,
                          decoration: const InputDecoration(
                            labelText: 'Sales Stage',
                            border: OutlineInputBorder(),
                          ),
                          items: stages
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.stageName, style: const TextStyle(fontSize: 13))))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStageId = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedInventoryType,
                          decoration: const InputDecoration(
                            labelText: 'Requirement',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: '1BHK', child: Text('1BHK')),
                            DropdownMenuItem(value: '2BHK', child: Text('2BHK')),
                            DropdownMenuItem(value: '3BHK', child: Text('3BHK')),
                            DropdownMenuItem(value: 'Villa', child: Text('Villa')),
                            DropdownMenuItem(value: 'Plot', child: Text('Plot')),
                            DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedInventoryType = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Budget & Location
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Budget (in Lakhs)',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Preferred Location',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Custom Fields Section
                  const Text(
                    'Dynamic Custom Fields (Sales Cycle Schema)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                  ),
                  const SizedBox(height: 8),

                  DynamicFormWidget(
                    fields: _dynamicFields,
                    initialValues: _customFieldsData,
                    onValuesChanged: (vals) {
                      _customFieldsData = vals;
                    },
                    onFieldAdded: (newField) {
                      setState(() {
                        _dynamicFields.add(newField);
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _handleSave,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F4C81)),
                      child: const Text('Save Client to Local CRM'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
