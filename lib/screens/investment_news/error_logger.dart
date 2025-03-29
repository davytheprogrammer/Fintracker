import 'package:flutter/foundation.dart';

void logError(String message, Object error) {
  if (kDebugMode) {
    print('ERROR: $message - $error');
  }
}
