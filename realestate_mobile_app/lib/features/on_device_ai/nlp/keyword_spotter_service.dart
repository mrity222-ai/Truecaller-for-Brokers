import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class SpotResult {
  final List<String> matchedKeywords;
  final Map<String, List<String>> matchedByCategory;

  SpotResult({
    required this.matchedKeywords,
    required this.matchedByCategory,
  });

  bool get hasMatches => matchedKeywords.isNotEmpty;
}

class KeywordSpotterService {
  static final KeywordSpotterService instance = KeywordSpotterService._internal();
  KeywordSpotterService._internal();

  bool _isInitialized = false;
  final Map<String, List<String>> _keywordsByCategory = {};

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Load default seed keywords from bundled asset
      final jsonString = await rootBundle.loadString('assets/ai_models/default_keywords_hindi.json');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      final categories = data['categories'] as Map<String, dynamic>;

      categories.forEach((catKey, catValue) {
        final kwList = (catValue['keywords'] as List).map((e) => e.toString()).toList();
        _keywordsByCategory[catKey] = kwList;
      });
    } catch (e) {
      // Fallback defaults if asset is missing or during tests
      _loadHardcodedFallbacks();
    }

    // 2. Load broker's custom enhanced keywords from local storage
    await _loadCustomKeywordsFromStorage();

    _isInitialized = true;
  }

  void _loadHardcodedFallbacks() {
    _keywordsByCategory['price_and_budget'] = ['बजट', 'लाख', 'करोड़', 'cr', 'lakh', 'फाइनल रेट', 'नेगोशिएबल'];
    _keywordsByCategory['inventory_and_configurations'] = ['1BHK', '2BHK', '3BHK', '4BHK', 'विला', 'प्लॉट', 'दुकान'];
    _keywordsByCategory['transaction_and_stages'] = ['बयाना', 'टोकन', 'रजिस्ट्री', 'साइट विजिट', 'दाखिल खारिज'];
    _keywordsByCategory['facing_and_direction'] = ['ईस्ट फेसिंग', 'नॉर्थ फेसिंग', 'पार्क फेसिंग', 'कॉर्नर'];
    _keywordsByCategory['legal_and_banking'] = ['बैंक लोन', 'होम लोन', 'PMAY', 'फ्रीहोल्ड'];
    _keywordsByCategory['possession_and_timeline'] = ['तुरंत शिफ्ट', 'रेडी टू मूव', 'अंडर कंस्ट्रक्शन'];
  }

  Future<File?> _getCustomKeywordsFile() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/custom_keywords_enhanced.json');
    } catch (e) {
      return null;
    }
  }

  Future<void> _loadCustomKeywordsFromStorage() async {
    try {
      final file = await _getCustomKeywordsFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);
        data.forEach((cat, list) {
          final existing = _keywordsByCategory[cat] ?? [];
          final customList = (list as List).map((e) => e.toString()).toList();
          for (var item in customList) {
            if (!existing.contains(item)) {
              existing.add(item);
            }
          }
          _keywordsByCategory[cat] = existing;
        });
      }
    } catch (e) {
      // Ignore if no custom file exists yet
    }
  }

  Future<void> _saveCustomKeywordsToStorage() async {
    try {
      final file = await _getCustomKeywordsFile();
      if (file != null) {
        await file.writeAsString(jsonEncode(_keywordsByCategory));
      }
    } catch (e) {
      // Non-blocking
    }
  }

  /// Spot keywords in a given conversation transcript
  SpotResult spotKeywords(String transcript) {
    final lowerText = transcript.toLowerCase();
    final List<String> allMatches = [];
    final Map<String, List<String>> byCategory = {};

    _keywordsByCategory.forEach((category, keywords) {
      final List<String> catMatches = [];
      for (var kw in keywords) {
        final lowerKw = kw.toLowerCase();
        if (lowerText.contains(lowerKw)) {
          catMatches.add(kw);
          if (!allMatches.contains(kw)) {
            allMatches.add(kw);
          }
        }
      }
      if (catMatches.isNotEmpty) {
        byCategory[category] = catMatches;
      }
    });

    return SpotResult(
      matchedKeywords: allMatches,
      matchedByCategory: byCategory,
    );
  }

  Map<String, List<String>> getAllKeywords() => Map.unmodifiable(_keywordsByCategory);

  Future<void> addCustomKeyword(String category, String keyword) async {
    final clean = keyword.trim();
    if (clean.isEmpty) return;

    final list = _keywordsByCategory[category] ?? [];
    if (!list.contains(clean)) {
      list.add(clean);
      _keywordsByCategory[category] = list;
      await _saveCustomKeywordsToStorage();
    }
  }

  Future<void> removeCustomKeyword(String category, String keyword) async {
    final list = _keywordsByCategory[category];
    if (list != null) {
      list.remove(keyword);
      _keywordsByCategory[category] = list;
      await _saveCustomKeywordsToStorage();
    }
  }
}
