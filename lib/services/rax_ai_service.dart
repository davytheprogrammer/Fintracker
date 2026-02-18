import 'dart:convert';
import 'package:http/http.dart' as http;

class RaxAIClient {
  final String apiKey;
  final String baseUrl;
  final http.Client _httpClient;

  RaxAIClient(this.apiKey,
      {this.baseUrl = 'https://ai.raxcore.dev/api/v1', http.Client? client})
      : _httpClient = client ?? http.Client();

  /// Send a chat completion request.
  ///
  /// [messages] should be a list of maps like: { 'role': 'user', 'content': 'Hello' }
  Future<String> createChatCompletion(List<Map<String, String>> messages,
      {String model = 'rax-4.5',
      double temperature = 0.7,
      int maxTokens = 1000}) async {
    final uri = Uri.parse('$baseUrl/chat/completions');
    final payload = jsonEncode({
      'model': model,
      'messages': messages,
      'temperature': temperature,
      'max_tokens': maxTokens,
    });

    const int maxRetries = 3;
    int attempt = 0;
    int delayMs = 1000;

    while (true) {
      attempt += 1;
      final resp = await _httpClient
          .post(uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $apiKey',
              },
              body: payload)
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;

        if (data.containsKey('choices') &&
            data['choices'] is List &&
            data['choices'].isNotEmpty) {
          final choice = data['choices'][0];
          if (choice is Map && choice.containsKey('message')) {
            final message = choice['message'];
            if (message is Map && message.containsKey('content')) {
              return message['content'].toString();
            }
          }
          if (choice is Map && choice.containsKey('text')) {
            return choice['text'].toString();
          }
        }

        return resp.body;
      }

      // Retry on rate limit (429) or server errors (5xx)
      if ((resp.statusCode == 429 ||
              (resp.statusCode >= 500 && resp.statusCode < 600)) &&
          attempt <= maxRetries) {
        await Future.delayed(Duration(milliseconds: delayMs));
        delayMs *= 2;
        continue;
      }

      throw Exception('Rax AI request failed: ${resp.statusCode} ${resp.body}');
    }
  }

  void close() => _httpClient.close();
}
