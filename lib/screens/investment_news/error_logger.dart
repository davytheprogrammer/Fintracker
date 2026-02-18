import 'package:flutter/foundation.dart';

void logError(String message, Object error) {
  if (kDebugMode) {
    debugPrint('ERROR: $message - $error');
  }
}
