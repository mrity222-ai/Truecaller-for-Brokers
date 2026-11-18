import 'package:flutter/material.dart';
import 'field_definition.dart';

class DynamicFormWidget extends StatefulWidget {
  final List<FieldDefinition> fields;
  final Map<String, dynamic> initialValues;
  final ValueChanged<Map<String, dynamic>> onValuesChanged;
  final ValueChanged<FieldDefinition>? onFieldAdded;

  const DynamicFormWidget({
    super.key,
    required this.fields,
    required this.initialValues,
    required this.onValuesChanged,
    this.onFieldAdded,
  });

  @override
  State<DynamicFormWidget> createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  late Map<String, dynamic> _currentValues;

  @override
  void initState() {
    super.initState();
    _currentValues = Map<String, dynamic>.from(widget.initialValues);
  }

  void _updateValue(String key, dynamic value) {
    setState(() {
      _currentValues[key] = value;
    });
    widget.onValuesChanged(_currentValues);
  }

  void _showAddCustomFieldDialog() {
    final keyController = TextEditingController();
    FieldType selectedType = FieldType.text;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Custom Field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'Field Name (e.g. Balcony Count, Token Date)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<FieldType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Field Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: FieldType.text, child: Text('Text')),
                  DropdownMenuItem(value: FieldType.number, child: Text('Number')),
                  DropdownMenuItem(value: FieldType.boolean, child: Text('Yes / No (Checkbox)')),
                  DropdownMenuItem(value: FieldType.date, child: Text('Date Picker')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final label = keyController.text.trim();
                if (label.isNotEmpty) {
                  final newField = FieldDefinition(
                    key: label.toLowerCase().replaceAll(' ', '_'),
                    label: label,
                    type: selectedType,
                  );
                  widget.onFieldAdded?.call(newField);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add Field'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.fields.map((field) => _buildFieldItem(field)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _showAddCustomFieldDialog,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Custom Field to this Client'),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldItem(FieldDefinition field) {
    switch (field.type) {
      case FieldType.text:
      case FieldType.number:
      case FieldType.currency:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            initialValue: _currentValues[field.key]?.toString() ?? '',
            keyboardType: field.type == FieldType.text
                ? TextInputType.text
                : TextInputType.number,
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onChanged: (val) => _updateValue(field.key, val),
          ),
        );

      case FieldType.boolean:
        final bool isChecked = _currentValues[field.key] == true;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            title: Text(field.label, style: const TextStyle(fontSize: 14)),
            value: isChecked,
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (val) => _updateValue(field.key, val ?? false),
          ),
        );

      case FieldType.dropdown:
        final currentVal = _currentValues[field.key]?.toString();
        final effectiveVal = field.options.contains(currentVal) ? currentVal : null;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<String>(
            value: effectiveVal,
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: field.options
                .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                .toList(),
            onChanged: (val) => _updateValue(field.key, val),
          ),
        );

      case FieldType.date:
        final currentVal = _currentValues[field.key]?.toString();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(field.label),
            subtitle: Text(currentVal ?? 'Select Date'),
            trailing: const Icon(Icons.calendar_today, size: 20),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                _updateValue(field.key, '${picked.day}/${picked.month}/${picked.year}');
              }
            },
          ),
        );
    }
  }
}
