class SalesStageEntity {
  final String id;
  final String stageName;
  final int stageOrder;
  final int colorHex;
  final int slaHours;
  final String description;

  const SalesStageEntity({
    required this.id,
    required this.stageName,
    required this.stageOrder,
    required this.colorHex,
    required this.slaHours,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'stageName': stageName,
    'stageOrder': stageOrder,
    'colorHex': colorHex,
    'slaHours': slaHours,
    'description': description,
  };

  factory SalesStageEntity.fromJson(Map<String, dynamic> json) => SalesStageEntity(
    id: json['id'] as String,
    stageName: json['stageName'] as String,
    stageOrder: json['stageOrder'] as int,
    colorHex: json['colorHex'] as int,
    slaHours: json['slaHours'] as int,
    description: json['description'] as String,
  );

  static List<SalesStageEntity> get defaultStages => const [
    SalesStageEntity(
      id: 'new_lead',
      stageName: 'New Lead',
      stageOrder: 1,
      colorHex: 0xFF1E88E5, // Blue
      slaHours: 24,
      description: 'Newly captured inquiries from phone calls and WhatsApp',
    ),
    SalesStageEntity(
      id: 'site_visit_scheduled',
      stageName: 'Site Visit',
      stageOrder: 2,
      colorHex: 0xFFFFA000, // Amber
      slaHours: 72,
      description: 'Physical walkthrough and society inspection scheduled',
    ),
    SalesStageEntity(
      id: 'token_biana_pending',
      stageName: 'Token / Biana',
      stageOrder: 3,
      colorHex: 0xFF8E24AA, // Purple
      slaHours: 120,
      description: 'Token advance, biana agreement, and loan approvals',
    ),
    SalesStageEntity(
      id: 'deal_closed',
      stageName: 'Deal Closed',
      stageOrder: 4,
      colorHex: 0xFF43A047, // Green
      slaHours: 0,
      description: 'Successful transaction, registration, and commission',
    ),
  ];
}
