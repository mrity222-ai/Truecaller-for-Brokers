import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../models/time_metric_models.dart';
import '../services/sales_velocity_calculator.dart';
import '../../call_manager/views/post_call_review_dialog.dart';

class TimeMatrixScreen extends StatefulWidget {
  const TimeMatrixScreen({super.key});

  @override
  State<TimeMatrixScreen> createState() => _TimeMatrixScreenState();
}

class _TimeMatrixScreenState extends State<TimeMatrixScreen> {
  bool _filterStalledOnly = false;

  @override
  void initState() {
    super.initState();
    AppDatabase.instance.init().then((_) {
      if (mounted) setState(() {});
    });
  }

  String _formatBudget(double budget) {
    if (budget >= 10000000) {
      return '₹${(budget / 10000000).toStringAsFixed(2)} Cr';
    } else {
      return '₹${(budget / 100000).toStringAsFixed(0)} Lakh';
    }
  }

  @override
  Widget build(BuildContext context) {
    final macro = SalesVelocityCalculator.calculateMacroSummary();
    final stageVelocities = SalesVelocityCalculator.calculateStageVelocities();
    var microCycles = SalesVelocityCalculator.calculateMicroCycles();

    if (_filterStalledOnly) {
      microCycles = microCycles.where((c) => c.isOverdue).toList();
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Macro Matrix KPIs
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Macro Sales Velocity Matrix',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.analytics_outlined, color: Color(0xFF0F4C81)),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _buildKpiCard(
                  'Avg Cycle Velocity',
                  '${macro.averageCycleDays.toStringAsFixed(1)} Days',
                  'From lead to close',
                  Icons.speed,
                  const Color(0xFF0F4C81),
                ),
                const SizedBox(width: 8),
                _buildKpiCard(
                  'Total Pipeline',
                  _formatBudget(macro.totalPipelineValueInr),
                  '${macro.activeDeals} Active Deals',
                  Icons.currency_rupee,
                  Colors.green.shade800,
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                _buildKpiCard(
                  'Conversion Rate',
                  '${macro.conversionRatePct.toStringAsFixed(0)}%',
                  '${macro.closedWonDeals} Deals Closed',
                  Icons.pie_chart_outline,
                  Colors.purple.shade700,
                ),
                const SizedBox(width: 8),
                _buildKpiCard(
                  'Bottlenecks',
                  '${macro.totalStalledDeals} Stalled',
                  'Exceeded stage SLA',
                  Icons.warning_amber_rounded,
                  macro.totalStalledDeals > 0 ? Colors.red.shade700 : Colors.grey.shade600,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 2: Stage Funnel Velocity Bars
            const Text(
              'Stage-by-Stage Velocity vs SLA',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: stageVelocities.map((metric) {
                    final slaDays = (metric.slaHours / 24).ceil();
                    final progress = slaDays > 0 ? (metric.averageDaysInStage / slaDays).clamp(0.05, 1.0) : 1.0;
                    final color = Color(metric.colorHex);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${metric.stageName} (${metric.leadsCount} leads)',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${metric.averageDaysInStage.toStringAsFixed(1)}d avg (SLA: ${slaDays > 0 ? "${slaDays}d" : "N/A"})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: metric.stalledCount > 0 ? Colors.red.shade700 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 7,
                              backgroundColor: color.withOpacity(0.15),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                metric.stalledCount > 0 ? Colors.red : color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section 3: Micro Time Matrix (Individual Client Cycles)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Micro Client Cycles',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                FilterChip(
                  label: const Text('Show Stalled Only', style: TextStyle(fontSize: 11)),
                  selected: _filterStalledOnly,
                  selectedColor: Colors.red.shade100,
                  onSelected: (val) => setState(() => _filterStalledOnly = val),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...microCycles.map((cycle) => _buildMicroCycleCard(cycle)),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicroCycleCard(ClientMicroCycle cycle) {
    final stageColor = Color(cycle.stageColorHex);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: cycle.isOverdue ? BorderSide(color: Colors.red.shade400, width: 1.5) : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Client Name + Stage + Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cycle.leadName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        cycle.phoneNumber,
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: stageColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        cycle.currentStageName,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: stageColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatBudget(cycle.budgetInr),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F4C81)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Days in Stage + Overdue Alert
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      cycle.isOverdue ? Icons.warning_amber : Icons.timer_outlined,
                      size: 15,
                      color: cycle.isOverdue ? Colors.red : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      cycle.isOverdue
                          ? '${cycle.daysInCurrentStage}d in this stage (SLA Overdue!)'
                          : '${cycle.daysInCurrentStage}d in current stage',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: cycle.isOverdue ? FontWeight.bold : FontWeight.normal,
                        color: cycle.isOverdue ? Colors.red.shade700 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Total Cycle: ${cycle.totalDaysSinceCreation}d',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Visual Cycle Progression Dots
            _buildStageProgressDots(cycle.currentStageId),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    PostCallReviewDialog.show(
                      context,
                      phoneNumber: cycle.phoneNumber,
                      initialName: cycle.leadName,
                      suggestedSummary: 'Velocity follow-up for ${cycle.leadName}.',
                      suggestedActionable: 'Call to push forward from ${cycle.currentStageName}.',
                      onSaved: () => setState(() {}),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('Advance Cycle', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageProgressDots(String currentStageId) {
    final stages = [
      {'id': 'new_lead', 'name': 'New'},
      {'id': 'site_visit_scheduled', 'name': 'Visit'},
      {'id': 'token_biana_pending', 'name': 'Token'},
      {'id': 'deal_closed', 'name': 'Closed'},
    ];

    int currentIndex = stages.indexWhere((s) => s['id'] == currentStageId);
    if (currentIndex < 0) currentIndex = 0;

    return Row(
      children: List.generate(stages.length * 2 - 1, (i) {
        if (i % 2 == 1) {
          // Connecting line
          final activeLine = (i ~/ 2) < currentIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: activeLine ? const Color(0xFF0F4C81) : Colors.grey.shade300,
            ),
          );
        } else {
          // Dot
          final dotIndex = i ~/ 2;
          final isCompleted = dotIndex <= currentIndex;
          return Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isCompleted ? const Color(0xFF0F4C81) : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 9, color: Colors.white)
                : null,
          );
        }
      }),
    );
  }
}
