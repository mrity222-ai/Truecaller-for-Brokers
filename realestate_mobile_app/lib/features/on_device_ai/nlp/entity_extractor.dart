import 'keyword_spotter_service.dart';

class ExtractedLeadPayload {
  final double budgetInr;
  final String unitType;
  final String inferredStageId;
  final String preferredLocation;
  final String summary;
  final String actionable;
  final DateTime? suggestedFollowUpDate;
  final List<String> spottedKeywords;
  final Map<String, dynamic> extractedCustomFields;

  ExtractedLeadPayload({
    required this.budgetInr,
    required this.unitType,
    required this.inferredStageId,
    required this.preferredLocation,
    required this.summary,
    required this.actionable,
    this.suggestedFollowUpDate,
    required this.spottedKeywords,
    this.extractedCustomFields = const {},
  });
}

class EntityExtractor {
  static ExtractedLeadPayload extract(String transcript) {
    final spotResult = KeywordSpotterService.instance.spotKeywords(transcript);
    final textLower = transcript.toLowerCase();

    // 1. Extract Budget
    final budgetInr = _extractBudget(transcript);

    // 2. Extract Unit Type
    final unitType = _extractUnitType(textLower);

    // 3. Infer Sales Stage
    final stageId = _inferStage(textLower, spotResult);

    // 4. Extract Location
    final location = _extractLocation(transcript);

    // 5. Extract Actionable & Follow-up date
    final followUp = _extractFollowUp(transcript);

    // 6. Generate Clean 2-Line Hindi Summary
    final summary = _generateSummary(transcript, unitType, budgetInr, location);

    // 7. Custom Fields mapping
    final customFields = <String, dynamic>{};
    if (textLower.contains('ईस्ट फेसिंग') || textLower.contains('east facing')) {
      customFields['Facing'] = 'East Facing';
    } else if (textLower.contains('पार्क फेसिंग') || textLower.contains('park facing')) {
      customFields['Facing'] = 'Park Facing';
    } else if (textLower.contains('कॉर्नर') || textLower.contains('corner')) {
      customFields['Facing'] = 'Corner Plot';
    }

    if (textLower.contains('लोन') || textLower.contains('loan')) {
      customFields['Loan Status'] = 'Home Loan Needed';
    }

    return ExtractedLeadPayload(
      budgetInr: budgetInr,
      unitType: unitType,
      inferredStageId: stageId,
      preferredLocation: location,
      summary: summary,
      actionable: followUp.actionable,
      suggestedFollowUpDate: followUp.date,
      spottedKeywords: spotResult.matchedKeywords,
      extractedCustomFields: customFields,
    );
  }

  static double _extractBudget(String text) {
    // Check for Crore (करोड़ / cr / crore)
    final crRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:करोड़|cr|crore|crores)', caseSensitive: false);
    final crMatch = crRegex.firstMatch(text);
    if (crMatch != null) {
      final val = double.tryParse(crMatch.group(1) ?? '');
      if (val != null) return val * 10000000;
    }

    // Check for Lakh (लाख / lakh / lac / lacs)
    final lakhRegex = RegExp(r'(\d+(?:\.\d+)?)\s*(?:लाख|lakh|lac|lacs)', caseSensitive: false);
    final lakhMatch = lakhRegex.firstMatch(text);
    if (lakhMatch != null) {
      final val = double.tryParse(lakhMatch.group(1) ?? '');
      if (val != null) return val * 100000;
    }

    // Fallback if plain number like 85 or 90 with budget
    final numRegex = RegExp(r'(?:बजट|budget)\s*(?:है|is)?\s*(\d{2,3})', caseSensitive: false);
    final numMatch = numRegex.firstMatch(text);
    if (numMatch != null) {
      final val = double.tryParse(numMatch.group(1) ?? '');
      if (val != null && val >= 20 && val <= 500) {
        return val * 100000; // Assume lakhs
      }
    }

    return 7500000; // Default 75 Lakhs if not specified
  }

  static String _extractUnitType(String textLower) {
    if (textLower.contains('4bhk') || textLower.contains('फोर बीएचके')) return '4BHK';
    if (textLower.contains('3bhk') || textLower.contains('थ्री बीएचके')) return '3BHK';
    if (textLower.contains('2bhk') || textLower.contains('टू बीएचके')) return '2BHK';
    if (textLower.contains('1bhk') || textLower.contains('वन बीएचके')) return '1BHK';
    if (textLower.contains('विला') || textLower.contains('villa')) return 'Villa';
    if (textLower.contains('प्लॉट') || textLower.contains('plot') || textLower.contains('गज')) return 'Plot';
    if (textLower.contains('दुकान') || textLower.contains('shop') || textLower.contains('कमर्शियल')) return 'Commercial';
    return '2BHK';
  }

  static String _inferStage(String textLower, SpotResult spotResult) {
    if (textLower.contains('रजिस्ट्री') || textLower.contains('registry') || textLower.contains('डील फाइनल')) {
      return 'deal_closed';
    }
    if (textLower.contains('बयाना') || textLower.contains('टोकन') || textLower.contains('token') || textLower.contains('biana')) {
      return 'token_biana_pending';
    }
    if (textLower.contains('विजिट') || textLower.contains('visit') || textLower.contains('देखने') || textLower.contains('शनिवार') || textLower.contains('कल')) {
      return 'site_visit_scheduled';
    }
    return 'new_lead';
  }

  static String _extractLocation(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('सेक्टर 137') || lower.contains('sector 137')) return 'Noida Sector 137';
    if (lower.contains('सेक्टर 150') || lower.contains('sector 150')) return 'Noida Sector 150';
    if (lower.contains('सेक्टर 62') || lower.contains('sector 62')) return 'Noida Sector 62';
    if (lower.contains('ग्रेटर नोएडा वेस्ट') || lower.contains('noida extension')) return 'Greater Noida West';
    if (lower.contains('ग्रेटर नोएडा') || lower.contains('greater noida')) return 'Greater Noida';
    if (lower.contains('यमुना एक्सप्रेसवे') || lower.contains('yamuna expressway')) return 'Yamuna Expressway';
    if (lower.contains('एक्सप्रेसवे') || lower.contains('expressway')) return 'Noida Expressway';
    if (lower.contains('गुड़गांव') || lower.contains('gurugram')) return 'Gurugram';
    return 'Noida';
  }

  static ({String actionable, DateTime date}) _extractFollowUp(String text) {
    final lower = text.toLowerCase();
    final now = DateTime.now();

    if (lower.contains('शनिवार') || lower.contains('saturday')) {
      return (
        actionable: 'शनिवार को साइट विजिट अरेंज करना है।',
        date: now.add(Duration(days: (6 - now.weekday + 7) % 7 == 0 ? 7 : (6 - now.weekday + 7) % 7)),
      );
    }
    if (lower.contains('रविवार') || lower.contains('sunday')) {
      return (
        actionable: 'रविवार को क्लाइंट को फ्लैट दिखाना है।',
        date: now.add(Duration(days: (7 - now.weekday + 7) % 7 == 0 ? 7 : (7 - now.weekday + 7) % 7)),
      );
    }
    if (lower.contains('कल') || lower.contains('tomorrow')) {
      return (
        actionable: 'कल सुबह क्लाइंट को प्रोजेक्ट ब्रोशर और प्राइस लिस्ट भेजना है।',
        date: now.add(const Duration(days: 1)),
      );
    }
    if (lower.contains('टोकन') || lower.contains('बयाना')) {
      return (
        actionable: 'टोकन अमाउंट और बैंक लोन सैंक्शन डिटेल्स कलेक्ट करना है।',
        date: now.add(const Duration(days: 2)),
      );
    }

    return (
      actionable: 'क्लाइंट को रिक्वायरमेंट्स के अनुसार 2-3 ऑप्शन शेयर करना है।',
      date: now.add(const Duration(days: 2)),
    );
  }

  static String _generateSummary(String raw, String unit, double budget, String location) {
    final budgetStr = budget >= 10000000
        ? '${(budget / 10000000).toStringAsFixed(2)} करोड़'
        : '${(budget / 100000).toStringAsFixed(0)} लाख';

    return 'क्लाइंट को $budgetStr तक में $location में $unit चाहिए। बातचीत के अनुसार फॉलो-अप और विजिट शेड्यूल की गई है।';
  }
}
