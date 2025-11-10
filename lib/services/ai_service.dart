import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  // Gemini API keys (same as used in other files)
  static const String _primaryGeminiKey =
      'AIzaSyDg8g0vPWjmVjZeIp9FLLEhPQboQwpHERc';
  static const String _secondaryGeminiKey =
      'AIzaSyDTA0CQeHhWY7dGl2i2CJuqCCWI4DFc1NM';

  // Together AI configuration
  static const String _togetherApiUrl =
      "https://api.together.xyz/v1/chat/completions";
  static const String _togetherApiKey =
      "4db152889da5afebdba262f90e4cdcf12976ee8b48d9135c2bb86ef9b0d12bdd";

  /// Generate AI insights for financial analytics
  Future<String> generateFinancialInsights(String prompt) async {
    return await _callAIWithFallback(prompt, 'financial_analytics');
  }

  /// Generate investment roadmap (JSON format)
  Future<String> generateInvestmentRoadmap(String prompt) async {
    return await _callAIWithFallback(prompt, 'investment_roadmap');
  }

  /// Generate personalized notification messages
  Future<String> generateNotificationMessage(String prompt) async {
    return await _callAIWithFallback(prompt, 'notification_message');
  }

  /// Clean and fix JSON responses
  Future<String> cleanJsonResponse(String dirtyJson) async {
    final prompt = '''
    IMPORTANT: Your ONLY task is to fix this JSON response.
    Return ONLY the corrected JSON without any additional text or markdown.
    Preserve all original content while fixing syntax errors.
    Ensure the output is valid JSON that can be parsed by Dart's json.decode().

    Here is the JSON to fix:
    $dirtyJson
    ''';

    return await _callGeminiOnly(prompt);
  }

  /// Main AI calling method with fallback strategy
  Future<String> _callAIWithFallback(String prompt, String context) async {
    // Try Together AI first
    try {
      return await _callTogetherAI(prompt, context);
    } catch (e) {
      print('Together AI failed for $context: $e');
      // Fall back to Gemini
      try {
        return await _callGeminiOnly(prompt);
      } catch (geminiError) {
        print('Gemini fallback also failed for $context: $geminiError');
        throw Exception(
            'All AI services failed. Together: $e, Gemini: $geminiError');
      }
    }
  }

  /// Call Together AI service
  Future<String> _callTogetherAI(String prompt, String context) async {
    final systemMessage = _getSystemMessage(context);

    final response = await http.post(
      Uri.parse(_togetherApiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_togetherApiKey",
      },
      body: json.encode({
        "model": "meta-llama/Llama-3.3-70B-Instruct-Turbo-Free",
        "messages": [
          {"role": "system", "content": systemMessage},
          {"role": "user", "content": prompt},
        ],
        "temperature": 0.7,
        "max_tokens": context == 'financial_analytics' ? 300 : 2000,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'].trim();
    } else {
      throw Exception('Together AI failed: ${response.statusCode}');
    }
  }

  /// Call Gemini AI with primary and secondary key fallback
  Future<String> _callGeminiOnly(String prompt) async {
    // Try primary Gemini key
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: _primaryGeminiKey,
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!.trim();
      } else {
        throw Exception('Primary Gemini returned empty response');
      }
    } catch (e) {
      print('Primary Gemini failed: $e');

      // Try secondary Gemini key
      final model = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: _secondaryGeminiKey,
      );

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      if (response.text != null && response.text!.isNotEmpty) {
        return response.text!.trim();
      } else {
        throw Exception('Secondary Gemini also returned empty response');
      }
    }
  }

  /// Get appropriate system message based on context
  String _getSystemMessage(String context) {
    switch (context) {
      case 'financial_analytics':
        return "You are a friendly financial advisor. Provide helpful, encouraging advice and do not provide a too long text";
      case 'investment_roadmap':
        return "You are an expert investment advisor. Provide detailed, accurate investment roadmaps in valid JSON format only.";
      case 'notification_message':
        return "You are a friendly financial coach. Generate short, encouraging messages for notifications.";
      default:
        return "You are a helpful AI assistant.";
    }
  }
}
