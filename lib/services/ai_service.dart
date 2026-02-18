import 'package:flutter/foundation.dart';
import 'package:Finspense/services/rax_ai_service.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal() {
    // Hardcoded Rax API key for now (replace with secure storage later)
    const _hardcodedRaxKey =
        'rax_7588fc4a18f563c72658cf8bb5acc43da94878ecfa9fa66f0f71c3f5aa7de8ce';
    _client = RaxAIClient(_hardcodedRaxKey);
    _initialized = true;
  }

  late RaxAIClient _client;
  bool _initialized = false;

  /// Initialize AIService with your Rax API key. Call once at app startup.
  void init(String apiKey) {
    if (!_initialized) {
      _client = RaxAIClient(apiKey);
      _initialized = true;
    }
  }

  void dispose() {
    if (_initialized) _client.close();
    _initialized = false;
  }

  Future<String> generateFinancialInsights(String prompt) async {
    return await _callRaxAI(prompt, 'financial_analytics');
  }

  Future<String> generateInvestmentRoadmap(String prompt) async {
    return await _callRaxAI(prompt, 'investment_roadmap');
  }

  Future<String> generateNotificationMessage(String prompt) async {
    return await _callRaxAI(prompt, 'notification_message');
  }

  Future<String> cleanJsonResponse(String dirtyJson) async {
    final prompt = '''
    IMPORTANT: Your ONLY task is to fix this JSON response.
    Return ONLY the corrected JSON without any additional text or markdown.
    Preserve all original content while fixing syntax errors.
    Ensure the output is valid JSON that can be parsed by Dart's json.decode().

    Here is the JSON to fix:
    $dirtyJson
    ''';

    return await _callRaxAI(prompt, 'clean_json');
  }

  Future<String> _callRaxAI(String prompt, String context) async {
    if (!_initialized)
      throw Exception('AIService not initialized. Call init(apiKey) first.');

    final systemMessage = _getSystemMessage(context);
    final messages = [
      {'role': 'system', 'content': systemMessage},
      {'role': 'user', 'content': prompt},
    ];

    int maxTokens = 1000;
    double temperature = 0.7;

    switch (context) {
      case 'financial_analytics':
        maxTokens = 300;
        temperature = 0.5;
        break;
      case 'investment_roadmap':
        maxTokens = 20000;
        temperature = 0.2;
        break;
      case 'notification_message':
        maxTokens = 60;
        temperature = 0.7;
        break;
      case 'clean_json':
        maxTokens = 300;
        temperature = 0.0;
        break;
      default:
        maxTokens = 1000;
        temperature = 0.7;
    }

    try {
      final resp = await _client.createChatCompletion(
        messages,
        model: 'rax-4.5',
        temperature: temperature,
        maxTokens: maxTokens,
      );

      return resp.trim();
    } catch (e) {
      debugPrint('Rax AI error for $context: $e');
      rethrow;
    }
  }

  String _getSystemMessage(String context) {
    const noReasoning =
        'Do NOT reveal internal chain-of-thought or step-by-step reasoning. Provide only the final answer; if an explanation is requested, keep it concise and high-level.';

    switch (context) {
      case 'financial_analytics':
        return 'You are a friendly, concise financial analyst. Provide clear, actionable insights focused on budgets, trends, and recommendations. ' +
            noReasoning;
      case 'investment_roadmap':
        return 'You are an expert investment advisor. Output a detailed investment roadmap in valid JSON when requested, including steps, time horizons, and risk notes. ' +
            noReasoning;
      case 'notification_message':
        return 'You are a friendly financial coach. Generate short, encouraging notification messages. ' +
            noReasoning;
      case 'clean_json':
        return 'You are a JSON fixer. Only output valid JSON and nothing else. ' +
            noReasoning;
      default:
        return ('You are a helpful AI assistant. ' + noReasoning);
    }
  }
}
