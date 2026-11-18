import 'dart:async';

enum RecognitionStatus {
  idle,
  listening,
  processing,
  completed,
  error,
}

class SpeechPreset {
  final String title;
  final String transcript;
  final String simulatedPhoneNumber;
  final String callerName;

  const SpeechPreset({
    required this.title,
    required this.transcript,
    required this.simulatedPhoneNumber,
    required this.callerName,
  });
}

class SpeechRecognitionService {
  static final SpeechRecognitionService instance = SpeechRecognitionService._internal();
  SpeechRecognitionService._internal();

  RecognitionStatus _status = RecognitionStatus.idle;
  RecognitionStatus get status => _status;

  final StreamController<String> _textStreamController = StreamController<String>.broadcast();
  Stream<String> get textStream => _textStreamController.stream;

  static const List<SpeechPreset> sampleRealEstateCalls = [
    SpeechPreset(
      title: '3BHK Site Visit Inquiry (Noida Sec 137)',
      callerName: 'Sunil Aggarwal',
      simulatedPhoneNumber: '+91 98991 23456',
      transcript: 'नमस्ते भैया, मुझे नोएडा सेक्टर 137 में रेडी टू मूव 3BHK फ्लैट देखना है। हमारा बजट 85 लाख तक का है। वाइफ को पार्क फेसिंग चाहिए। शनिवार 4 बजे साइट विजिट करा सकते हैं क्या?',
    ),
    SpeechPreset(
      title: 'Luxury Villa with Token (Greater Noida)',
      callerName: 'Anil Mehra',
      simulatedPhoneNumber: '+91 98100 44556',
      transcript: 'ग्रेटर नोएडा वेस्ट में विला के लिए कॉल किया था। 1.5 करोड़ तक का बजट है। बैंक लोन अप्रूव हो गया है। अगर पेपर्स सही हैं तो 2 लाख टोकन अमाउंट देकर डील पक्की कर सकते हैं।',
    ),
    SpeechPreset(
      title: 'Commercial Shop / Plot (Yamuna Expressway)',
      callerName: 'Mahesh Sharma',
      simulatedPhoneNumber: '+91 97112 33445',
      transcript: 'यमुना एक्सप्रेसवे पर 150 गज का रेजिडेंशियल प्लॉट या मेन रोड पर दुकान चाहिए। 55 लाख तक कैश बजट है। दाखिल खारिज और रजिस्ट्री तुरंत होनी चाहिए। कल डिटेल्स भेजिएगा।',
    ),
  ];

  Future<void> simulateSpeechRecognition(String fullText) async {
    _status = RecognitionStatus.listening;
    final words = fullText.split(' ');
    String accumulated = '';

    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      accumulated += (i == 0 ? '' : ' ') + words[i];
      _textStreamController.add(accumulated);
    }

    _status = RecognitionStatus.completed;
  }

  void stop() {
    _status = RecognitionStatus.idle;
  }
}
