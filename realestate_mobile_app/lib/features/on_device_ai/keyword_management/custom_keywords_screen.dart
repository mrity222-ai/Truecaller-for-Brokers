import 'package:flutter/material.dart';
import '../nlp/keyword_spotter_service.dart';

class CustomKeywordsScreen extends StatefulWidget {
  const CustomKeywordsScreen({super.key});

  @override
  State<CustomKeywordsScreen> createState() => _CustomKeywordsScreenState();
}

class _CustomKeywordsScreenState extends State<CustomKeywordsScreen> {
  final Map<String, String> _categoryDisplayNames = {
    'price_and_budget': '💰 Price & Budget (बजट, लाख, करोड़)',
    'inventory_and_configurations': '🏢 Property Types (2BHK, 3BHK, विला, प्लॉट)',
    'transaction_and_stages': '🤝 Transaction Stages (बयाना, टोकन, रजिस्ट्री)',
    'facing_and_direction': '🧭 Facing & Locality (ईस्ट फेसिंग, पार्क फेसिंग)',
    'legal_and_banking': '⚖️ Legal & Banking (बैंक लोन, PMAY, फ्रीहोल्ड)',
    'possession_and_timeline': '⏳ Possession & Urgency (रेडी टू मूव, तुरंत शिफ्ट)',
  };

  @override
  void initState() {
    super.initState();
    KeywordSpotterService.instance.init().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showAddKeywordDialog(String categoryKey, String categoryTitle) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Keyword to\n$categoryTitle', style: const TextStyle(fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. काठा, बिस्वा, सुपरटेक, गौर सिटी',
            labelText: 'New Hindi / Hinglish Term',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final term = controller.text.trim();
              if (term.isNotEmpty) {
                await KeywordSpotterService.instance.addCustomKeyword(categoryKey, term);
                if (mounted) {
                  setState(() {});
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added "$term" to keywords!')),
                  );
                }
              }
            },
            child: const Text('Add Term'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allKeywords = KeywordSpotterService.instance.getAllKeywords();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Real Estate Hindi Keywords', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF0F4C81).withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF0F4C81)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'These keywords are spotted on-device during client calls to auto-fill property forms and extract insights.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...allKeywords.entries.map((entry) {
            final catKey = entry.key;
            final keywords = entry.value;
            final title = _categoryDisplayNames[catKey] ?? catKey;

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showAddKeywordDialog(catKey, title),
                          icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0F4C81)),
                          tooltip: 'Add custom term',
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: keywords.map((kw) {
                        return Chip(
                          label: Text(kw, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () async {
                            await KeywordSpotterService.instance.removeCustomKeyword(catKey, kw);
                            setState(() {});
                          },
                          visualDensity: VisualDensity.compact,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
