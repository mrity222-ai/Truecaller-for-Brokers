enum FieldType {
  text,
  number,
  currency,
  boolean,
  dropdown,
  date,
}

class FieldDefinition {
  final String key;
  final String label;
  final FieldType type;
  final List<String> options;
  final bool isRequired;
  final dynamic defaultValue;

  const FieldDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.options = const [],
    this.isRequired = false,
    this.defaultValue,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'type': type.name,
    'options': options,
    'isRequired': isRequired,
    'defaultValue': defaultValue,
  };

  factory FieldDefinition.fromJson(Map<String, dynamic> json) => FieldDefinition(
    key: json['key'] as String,
    label: json['label'] as String,
    type: FieldType.values.byName(json['type'] as String? ?? 'text'),
    options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
    isRequired: json['isRequired'] as bool? ?? false,
    defaultValue: json['defaultValue'],
  );

  static List<FieldDefinition> get defaultRealEstateFields => const [
    FieldDefinition(
      key: 'facing',
      label: 'Facing Direction',
      type: FieldType.dropdown,
      options: ['East Facing', 'North-East', 'Park Facing', 'Corner Plot', 'Road Facing'],
    ),
    FieldDefinition(
      key: 'decision_maker',
      label: 'Key Decision Maker',
      type: FieldType.text,
    ),
    FieldDefinition(
      key: 'loan_status',
      label: 'Bank Loan Required',
      type: FieldType.dropdown,
      options: ['Pre-approved SBI/HDFC', 'Self Finance', 'Loan Needed', 'Applied'],
    ),
    FieldDefinition(
      key: 'cab_needed',
      label: 'Cab / Pickup Needed for Visit',
      type: FieldType.boolean,
    ),
  ];
}
