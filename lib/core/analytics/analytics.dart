import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

/// Аналітика через HTTP API Amplitude (офіційний SDK не підтримує Windows).
/// Ключ задається через --dart-define=AMPLITUDE_API_KEY=...; без нього події не надсилаються.
class Analytics {
  static const _apiKey = String.fromEnvironment('AMPLITUDE_API_KEY');
  // device_id має бути не коротшим за 5 символів; один на запуск застосунку.
  static final _deviceId = 'win-${Random().nextInt(1 << 32).toRadixString(36)}';

  static Future<void> track(String event, {String? userId, Map<String, Object?>? props}) async {
    if (_apiKey.isEmpty) return;
    final client = HttpClient();
    try {
      final req = await client.postUrl(Uri.parse('https://api2.amplitude.com/2/httpapi'));
      req.headers.contentType = ContentType.json;
      req.write(jsonEncode({
        'api_key': _apiKey,
        'events': [
          {
            'event_type': event,
            'device_id': _deviceId,
            if (userId != null) 'user_id': userId,
            'platform': 'Windows',
            if (props != null) 'event_properties': props,
          }
        ],
      }));
      final res = await req.close();
      await res.drain<void>();
    } catch (e) {
      debugPrint('Analytics error: $e'); // аналітика не має ламати застосунок
    } finally {
      client.close();
    }
  }
}
