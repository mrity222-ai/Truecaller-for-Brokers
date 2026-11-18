import 'package:flutter/material.dart';
import '../nlp/keyword_spotter_service.dart';
import '../nlp/entity_extractor.dart';
import '../stt/speech_recognition_service.dart';
import '../../call_manager/views/post_call_review_dialog.dart';

class AISimulatorScreen extends StatefulWidget {
  const AISimulatorScreen({super.key});

  @override
  State<AISimulatorScreen> createState() => _AISimulatorScreenState();
}

class _AISimulatorScreenState extends State<AISimulatorScreen> {
  final TextEditingController _transcriptController = TextEditingController();
  ExtractedLeadPayload? _extractedPayload;
  bool _isProcessing = false;
  String _selectedCallerName = 'Sunil Aggarwal';
  String _selectedPhone = '+91 98991 23456';

  @override
  void initState() {
    super.initState();
    KeywordSpotterService.instance.init();
    // Pre-fill with Preset 1
    final preset = SpeechRecognitionService.sampleRealEstateCalls.first;
    _transcriptController.text = preset.transcript;
    _selectedCallerName = preset.callerName;
    _selectedPhone = preset.simulatedPhoneNumber;
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  void _runAIAnalysis() {
    final text = _transcriptController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isProcessing = true);

    Future.delayed(const Duration(milliseconds: 200), () {
      final payload = EntityExtractor.extract(text);
      if (mounted) {
        setState(() {
          _extractedPayload = payload;
          _isProcessing = false;
        });
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Speech & NLP Simulator', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Presets Dropdown
            const Text(
              'Select Sample Real Estate Call Preset:',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SpeechRecognitionService.sampleRealEstateCalls.map((preset) {
                final isSelected = _selectedPhone == preset.simulatedPhoneNumber;
                return ChoiceChip(
                  label: Text(preset.title, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: const Color(0xFF0F4C81).withOpacity(0.15),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _transcriptController.text = preset.transcript;
                        _selectedCallerName = preset.callerName;
                        _selectedPhone = preset.simulatedPhoneNumber;
                        _extractedPayload = null;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Transcript Input
            TextField(
              controller: _transcriptController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Conversation Transcript (Hindi / Hinglish)',
                hintText: 'Type or speak conversation text here...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _isProcessing ? null : _runAIAnalysis,
                icon: const Icon(Icons.psychology),
                label: Text(_isProcessing ? 'Processing with Edge Model...' : 'Analyze Conversation with AI'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C81),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Results Section
            if (_extractedPayload != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Extracted Intelligence',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.offline_bolt, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          '100% On-Device',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Metric Cards
              Row(
                children: [
                  _buildMetricTile('Budget', _formatBudget(_extractedPayload!.budgetInr), Icons.currency_rupee, Colors.green),
                  const SizedBox(width: 8),
                  _buildMetricTile('Unit Type', _extractedPayload!.unitType, Icons.apartment, Colors.blue),
                  const SizedBox(width: 8),
                  _buildMetricTile('Inferred Stage', _extractedPayload!.inferredStageId.replaceAll('_', ' ').toUpperCase(), Icons.flag_outlined, Colors.purple),
                ],
              ),
              const SizedBox(height: 12),

              // Location & Actionable
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: Colors.red),
                          const SizedBox(width: 6),
                          Text(
                            'Location: ${_extractedPayload!.preferredLocation}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 18, color: Colors.blue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Action: ${_extractedPayload!.actionable}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Summary: ${_extractedPayload!.summary}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Spotted Keywords Chips
              const Text(
                'Spotted Real Estate Keywords:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _extractedPayload!.spottedKeywords.map((kw) {
                  return Chip(
                    label: Text(kw, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    backgroundColor: const Color(0xFF0F4C81).withOpacity(0.1),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Button to trigger post call review dialog
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    PostCallReviewDialog.show(
                      context,
                      phoneNumber: _selectedPhone,
                      initialName: _selectedCallerName,
                      suggestedSummary: _extractedPayload!.summary,
                      suggestedActionable: _extractedPayload!.actionable,
                    );
                  },
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Open Pre-Filled Post-Call Dialog'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F4C81),
                    side: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
