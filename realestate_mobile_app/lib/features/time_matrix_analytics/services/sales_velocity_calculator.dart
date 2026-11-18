import '../../../core/database/app_database.dart';
import '../models/time_metric_models.dart';

class SalesVelocityCalculator {
  static MacroPipelineSummary calculateMacroSummary() {
    final leads = AppDatabase.instance.getAllLeads();
    final stages = AppDatabase.instance.getAllStages();

    if (leads.isEmpty) {
      return MacroPipelineSummary(
        totalLeads: 0,
        totalPipelineValueInr: 0,
        averageCycleDays: 0,
        activeDeals: 0,
        closedWonDeals: 0,
        conversionRatePct: 0,
        totalStalledDeals: 0,
      );
    }

    final totalValue = leads.fold<double>(0, (sum, l) => sum + l.budgetInr);
    final closedDeals = leads.where((l) => l.currentStageId == 'deal_closed').length;
    final activeDeals = leads.length - closedDeals;
    final conversionRate = (closedDeals / leads.length) * 100;

    int stalledCount = 0;
    double totalCycleDays = 0;
    final now = DateTime.now();

    for (var lead in leads) {
      final daysSinceCreated = now.difference(lead.createdAt).inDays;
      totalCycleDays += daysSinceCreated > 0 ? daysSinceCreated : 1;

      final stage = stages.firstWhere((s) => s.id == lead.currentStageId, orElse: () => stages.first);
      final daysInStage = now.difference(lead.updatedAt).inDays;
      final slaDays = (stage.slaHours / 24).ceil();

      if (slaDays > 0 && daysInStage > slaDays) {
        stalledCount++;
      }
    }

    final avgCycleDays = leads.isNotEmpty ? (totalCycleDays / leads.length) : 0.0;

    return MacroPipelineSummary(
      totalLeads: leads.length,
      totalPipelineValueInr: totalValue,
      averageCycleDays: avgCycleDays,
      activeDeals: activeDeals,
      closedWonDeals: closedDeals,
      conversionRatePct: conversionRate,
      totalStalledDeals: stalledCount,
    );
  }

  static List<StageVelocityMetric> calculateStageVelocities() {
    final leads = AppDatabase.instance.getAllLeads();
    final stages = AppDatabase.instance.getAllStages();
    final now = DateTime.now();

    return stages.map((stage) {
      final stageLeads = leads.where((l) => l.currentStageId == stage.id).toList();
      final slaDays = (stage.slaHours / 24).ceil();

      double totalDays = 0;
      int stalled = 0;

      for (var l in stageLeads) {
        final days = now.difference(l.updatedAt).inDays;
        totalDays += days > 0 ? days : 1;
        if (slaDays > 0 && days > slaDays) {
          stalled++;
        }
      }

      final avgDays = stageLeads.isNotEmpty ? (totalDays / stageLeads.length) : 0.0;

      return StageVelocityMetric(
        stageId: stage.id,
        stageName: stage.stageName,
        averageDaysInStage: avgDays,
        leadsCount: stageLeads.length,
        colorHex: stage.colorHex,
        slaHours: stage.slaHours,
        stalledCount: stalled,
      );
    }).toList();
  }

  static List<ClientMicroCycle> calculateMicroCycles() {
    final leads = AppDatabase.instance.getAllLeads();
    final stages = AppDatabase.instance.getAllStages();
    final now = DateTime.now();

    return leads.map((lead) {
      final stage = stages.firstWhere((s) => s.id == lead.currentStageId, orElse: () => stages.first);
      final daysInStage = now.difference(lead.updatedAt).inDays;
      final totalDays = now.difference(lead.createdAt).inDays;
      final slaDays = (stage.slaHours / 24).ceil();

      final isOverdue = slaDays > 0 && daysInStage > slaDays;
      double healthScore = 1.0;
      if (slaDays > 0) {
        healthScore = (1.0 - (daysInStage / (slaDays * 1.5))).clamp(0.1, 1.0);
      }

      return ClientMicroCycle(
        leadId: lead.id,
        leadName: lead.name,
        phoneNumber: lead.phoneNumber,
        currentStageId: lead.currentStageId,
        currentStageName: stage.stageName,
        stageColorHex: stage.colorHex,
        daysInCurrentStage: daysInStage,
        totalDaysSinceCreation: totalDays > 0 ? totalDays : 1,
        budgetInr: lead.budgetInr,
        isOverdue: isOverdue,
        healthScore: healthScore,
      );
    }).toList();
  }
}
