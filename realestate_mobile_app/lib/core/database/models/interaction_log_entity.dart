class InteractionLogEntity {
  final String id;
  final String leadId;
  final String phoneNumber;
  final int durationSeconds;
  final String hindiSummary;
  final String actionItem;
  final DateTime? followUpDate;
  final String? audioRecordingPath;
  final DateTime createdAt;

  InteractionLogEntity({
    required this.id,
    required this.leadId,
    required this.phoneNumber,
    required this.durationSeconds,
    required this.hindiSummary,
    required this.actionItem,
    this.followUpDate,
    this.audioRecordingPath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'leadId': leadId,
    'phoneNumber': phoneNumber,
    'durationSeconds': durationSeconds,
    'hindiSummary': hindiSummary,
    'actionItem': actionItem,
    'followUpDate': followUpDate?.toIso8601String(),
    'audioRecordingPath': audioRecordingPath,
    'createdAt': createdAt.toIso8601String(),
  };

  factory InteractionLogEntity.fromJson(Map<String, dynamic> json) => InteractionLogEntity(
    id: json['id'] as String,
    leadId: json['leadId'] as String,
    phoneNumber: json['phoneNumber'] as String,
    durationSeconds: json['durationSeconds'] as int? ?? 0,
    hindiSummary: json['hindiSummary'] as String? ?? '',
    actionItem: json['actionItem'] as String? ?? '',
    followUpDate: json['followUpDate'] != null ? DateTime.parse(json['followUpDate'] as String) : null,
    audioRecordingPath: json['audioRecordingPath'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
