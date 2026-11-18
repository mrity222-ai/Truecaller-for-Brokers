class StageVelocityMetric {
  final String stageId;
  final String stageName;
  final double averageDaysInStage;
  final int leadsCount;
  final int colorHex;
  final int slaHours;
  final int stalledCount;

  StageVelocityMetric({
    required this.stageId,
    required this.stageName,
    required this.averageDaysInStage,
    required this.leadsCount,
    required this.colorHex,
    required this.slaHours,
    required this.stalledCount,
  });
}

class MacroPipelineSummary {
  final int totalLeads;
  final double totalPipelineValueInr;
  final double averageCycleDays;
  final int activeDeals;
  final int closedWonDeals;
  final double conversionRatePct;
  final int totalStalledDeals;

  MacroPipelineSummary({
    required this.totalLeads,
    required this.totalPipelineValueInr,
    required this.averageCycleDays,
    required this.activeDeals,
    required this.closedWonDeals,
    required this.conversionRatePct,
    required this.totalStalledDeals,
  });
}

class ClientMicroCycle {
  final String leadId;
  final String leadName;
  final String phoneNumber;
  final String currentStageId;
  final String currentStageName;
  final int stageColorHex;
  final int daysInCurrentStage;
  final int totalDaysSinceCreation;
  final double budgetInr;
  final bool isOverdue;
  final double healthScore; // 0.0 to 1.0

  ClientMicroCycle({
    required this.leadId,
    required this.leadName,
    required this.phoneNumber,
    required this.currentStageId,
    required this.currentStageName,
    required this.stageColorHex,
    required this.daysInCurrentStage,
    required this.totalDaysSinceCreation,
    required this.budgetInr,
    required this.isOverdue,
    required this.healthScore,
  });
}
