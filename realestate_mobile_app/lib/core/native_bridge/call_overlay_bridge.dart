import 'package:flutter/services.dart';

class CallOverlayBridge {
  static const MethodChannel _channel = MethodChannel('com.realestate.crm/native_bridge');

  /// Check if SYSTEM_ALERT_WINDOW (Draw over other apps) permission is granted
  static Future<bool> checkOverlayPermission() async {
    try {
      final bool hasPermission = await _channel.invokeMethod('checkOverlayPermission');
      return hasPermission;
    } on PlatformException catch (e) {
      print('Failed to check overlay permission: ${e.message}');
      return false;
    }
  }

  /// Direct the user to Android Settings to allow Draw Over Other Apps
  static Future<bool> requestOverlayPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestOverlayPermission');
      return result;
    } on PlatformException catch (e) {
      print('Failed to request overlay permission: ${e.message}');
      return false;
    }
  }

  /// Programmatically trigger the floating card (useful for testing or outgoing calls)
  static Future<void> showFloatingOverlay({
    required String clientName,
    required String clientStage,
    required String lastSummary,
    required String icebreaker,
    String phoneNumber = '',
  }) async {
    try {
      await _channel.invokeMethod('showFloatingOverlay', {
        'clientName': clientName,
        'clientStage': clientStage,
        'lastSummary': lastSummary,
        'icebreaker': icebreaker,
        'phoneNumber': phoneNumber,
      });
    } on PlatformException catch (e) {
      print('Failed to launch floating overlay: ${e.message}');
    }
  }

  /// Dismiss the floating overlay
  static Future<void> hideFloatingOverlay() async {
    try {
      await _channel.invokeMethod('hideFloatingOverlay');
    } on PlatformException catch (e) {
      print('Failed to hide floating overlay: ${e.message}');
    }
  }
}
