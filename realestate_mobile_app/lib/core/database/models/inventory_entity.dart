class InventoryEntity {
  final String id;
  final String projectName;
  final String unitNumber;
  final String unitType;
  final double superAreaSqft;
  final double askingPriceInr;
  final String status; // 'AVAILABLE', 'BLOCKED', 'SOLD'
  final String location;
  final Map<String, dynamic> customSpecs;
  final DateTime createdAt;

  InventoryEntity({
    required this.id,
    required this.projectName,
    required this.unitNumber,
    required this.unitType,
    required this.superAreaSqft,
    required this.askingPriceInr,
    this.status = 'AVAILABLE',
    required this.location,
    this.customSpecs = const {},
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectName': projectName,
    'unitNumber': unitNumber,
    'unitType': unitType,
    'superAreaSqft': superAreaSqft,
    'askingPriceInr': askingPriceInr,
    'status': status,
    'location': location,
    'customSpecs': customSpecs,
    'createdAt': createdAt.toIso8601String(),
  };

  factory InventoryEntity.fromJson(Map<String, dynamic> json) => InventoryEntity(
    id: json['id'] as String,
    projectName: json['projectName'] as String,
    unitNumber: json['unitNumber'] as String,
    unitType: json['unitType'] as String,
    superAreaSqft: (json['superAreaSqft'] as num).toDouble(),
    askingPriceInr: (json['askingPriceInr'] as num).toDouble(),
    status: json['status'] as String? ?? 'AVAILABLE',
    location: json['location'] as String? ?? '',
    customSpecs: Map<String, dynamic>.from(json['customSpecs'] as Map? ?? {}),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
