import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/models/inventory_entity.dart';
import '../../leads_crm/dynamic_schema/field_definition.dart';
import '../../leads_crm/dynamic_schema/dynamic_form_widget.dart';

class AddEditInventoryDialog extends StatefulWidget {
  final InventoryEntity? item;
  final VoidCallback? onSaved;

  const AddEditInventoryDialog({super.key, this.item, this.onSaved});

  static Future<void> show(BuildContext context, {InventoryEntity? item, VoidCallback? onSaved}) {
    return showDialog(
      context: context,
      builder: (ctx) => AddEditInventoryDialog(item: item, onSaved: onSaved),
    );
  }

  @override
  State<AddEditInventoryDialog> createState() => _AddEditInventoryDialogState();
}

class _AddEditInventoryDialogState extends State<AddEditInventoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _projectController;
  late TextEditingController _unitNumberController;
  late TextEditingController _priceController;
  late TextEditingController _areaController;
  late TextEditingController _locationController;

  String _selectedUnitType = '3BHK';
  String _selectedStatus = 'AVAILABLE';
  Map<String, dynamic> _customSpecs = {};
  List<FieldDefinition> _dynamicFields = [];

  @override
  void initState() {
    super.initState();
    _projectController = TextEditingController(text: widget.item?.projectName ?? '');
    _unitNumberController = TextEditingController(text: widget.item?.unitNumber ?? '');
    _priceController = TextEditingController(
      text: widget.item != null ? (widget.item!.askingPriceInr / 100000).toStringAsFixed(0) : '85',
    );
    _areaController = TextEditingController(
      text: widget.item != null ? widget.item!.superAreaSqft.toStringAsFixed(0) : '1450',
    );
    _locationController = TextEditingController(text: widget.item?.location ?? 'Noida Sector 137');
    _selectedUnitType = widget.item?.unitType ?? '3BHK';
    _selectedStatus = widget.item?.status ?? 'AVAILABLE';
    _customSpecs = Map<String, dynamic>.from(widget.item?.customSpecs ?? {});

    _dynamicFields = [
      const FieldDefinition(
        key: 'facing',
        label: 'Facing Direction',
        type: FieldType.dropdown,
        options: ['Park Facing', 'East Facing', 'North-East', 'Road Facing', 'Corner Plot'],
      ),
      const FieldDefinition(
        key: 'furnishing',
        label: 'Furnishing State',
        type: FieldType.dropdown,
        options: ['Fully Furnished', 'Semi-Furnished', 'Bare Shell / Raw'],
      ),
      const FieldDefinition(
        key: 'key_location',
        label: 'Key / Lockbox Location',
        type: FieldType.text,
      ),
      const FieldDefinition(
        key: 'owner_token_demand',
        label: 'Owner Min Token Demand',
        type: FieldType.text,
      ),
    ];

    // Inject extra custom specs from existing item
    _customSpecs.forEach((k, v) {
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
    _projectController.dispose();
    _unitNumberController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final priceLakhs = double.tryParse(_priceController.text.trim()) ?? 85.0;
    final area = double.tryParse(_areaController.text.trim()) ?? 1450.0;

    final item = InventoryEntity(
      id: widget.item?.id ?? const Uuid().v4(),
      projectName: _projectController.text.trim(),
      unitNumber: _unitNumberController.text.trim(),
      unitType: _selectedUnitType,
      superAreaSqft: area,
      askingPriceInr: priceLakhs * 100000,
      status: _selectedStatus,
      location: _locationController.text.trim(),
      customSpecs: _customSpecs,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
    );

    await AppDatabase.instance.saveInventory(item);

    if (mounted) {
      Navigator.pop(context);
      widget.onSaved?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
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
                        widget.item == null ? 'Add Site / Unit Inventory' : 'Edit Inventory Details',
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

                  // Project Name & Unit Number
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _projectController,
                          decoration: const InputDecoration(
                            labelText: 'Project / Society Name *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.apartment),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Project is required' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _unitNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Unit / Flat # *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Unit Type & Status
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnitType,
                          decoration: const InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: '1BHK', child: Text('1BHK')),
                            DropdownMenuItem(value: '2BHK', child: Text('2BHK')),
                            DropdownMenuItem(value: '3BHK', child: Text('3BHK')),
                            DropdownMenuItem(value: '4BHK', child: Text('4BHK')),
                            DropdownMenuItem(value: 'Villa', child: Text('Villa')),
                            DropdownMenuItem(value: 'Plot', child: Text('Plot')),
                            DropdownMenuItem(value: 'Commercial', child: Text('Commercial')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedUnitType = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'AVAILABLE', child: Text('🟢 Available')),
                            DropdownMenuItem(value: 'BLOCKED', child: Text('🟡 Blocked / Token')),
                            DropdownMenuItem(value: 'SOLD', child: Text('🔴 Sold / Registered')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price (Lakhs) & Super Area
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price (in Lakhs) *',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _areaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Super Area (Sqft/Sqyd)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location / Sector / Landmark',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dynamic Schema Specifications Section
                  const Text(
                    'Custom Inventory Attributes (Dynamic Schema)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                  ),
                  const SizedBox(height: 8),

                  DynamicFormWidget(
                    fields: _dynamicFields,
                    initialValues: _customSpecs,
                    onValuesChanged: (vals) {
                      _customSpecs = vals;
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
                      child: const Text('Save to Inventory Master'),
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
