class LeadEntity {
  final String id;
  final String name;
  final String phoneNumber;
  final String currentStageId;
  final double budgetInr;
  final String preferredLocation;
  final String inventoryType;
  final Map<String, dynamic> customFieldsData;
  final bool isClient;
  final bool isSynced;
  final DateTime lastContactedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  LeadEntity({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.currentStageId,
    required this.budgetInr,
    required this.preferredLocation,
    required this.inventoryType,
    this.customFieldsData = const {},
    this.isClient = true,
    this.isSynced = false,
    required this.lastContactedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCold {
    final difference = DateTime.now().difference(lastContactedAt).inDays;
    return difference >= 5;
  }

  int get daysSinceContact => DateTime.now().difference(lastContactedAt).inDays;

  LeadEntity copyWith({
    String? name,
    String? phoneNumber,
    String? currentStageId,
    double? budgetInr,
    String? preferredLocation,
    String? inventoryType,
    Map<String, dynamic>? customFieldsData,
    bool? isClient,
    bool? isSynced,
    DateTime? lastContactedAt,
    DateTime? updatedAt,
  }) {
    return LeadEntity(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      currentStageId: currentStageId ?? this.currentStageId,
      budgetInr: budgetInr ?? this.budgetInr,
      preferredLocation: preferredLocation ?? this.preferredLocation,
      inventoryType: inventoryType ?? this.inventoryType,
      customFieldsData: customFieldsData ?? this.customFieldsData,
      isClient: isClient ?? this.isClient,
      isSynced: isSynced ?? this.isSynced,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'currentStageId': currentStageId,
    'budgetInr': budgetInr,
    'preferredLocation': preferredLocation,
    'inventoryType': inventoryType,
    'customFieldsData': customFieldsData,
    'isClient': isClient,
    'isSynced': isSynced,
    'lastContactedAt': lastContactedAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory LeadEntity.fromJson(Map<String, dynamic> json) => LeadEntity(
    id: json['id'] as String,
    name: json['name'] as String,
    phoneNumber: json['phoneNumber'] as String,
    currentStageId: json['currentStageId'] as String,
    budgetInr: (json['budgetInr'] as num).toDouble(),
    preferredLocation: json['preferredLocation'] as String,
    inventoryType: json['inventoryType'] as String? ?? '2BHK',
    customFieldsData: Map<String, dynamic>.from(json['customFieldsData'] as Map? ?? {}),
    isClient: json['isClient'] as bool? ?? true,
    isSynced: json['isSynced'] as bool? ?? false,
    lastContactedAt: DateTime.parse(json['lastContactedAt'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}
