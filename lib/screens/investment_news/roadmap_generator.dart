import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../services/user_services.dart';
import '../../services/ai_service.dart';
import 'error_logger.dart';

class RoadmapGenerator {
  static final AIService _aiService = AIService();

  static String _getCurrentDate() {
    return DateFormat('MMMM dd, yyyy').format(DateTime.now());
  }

  static Future<String> _getCurrencySymbol() async {
    try {
      final userService = UserService();
      final userModel = await userService.getCurrentUserData();
      return userModel.currency?.symbol ?? 'KES'; // Default to KES
    } catch (e) {
      logError('Failed to get currency symbol', e);
      return 'KES'; // Fallback to KES
    }
  }

  static Future<void> generateRoadmap({
    required TextEditingController ideaController,
    required TextEditingController budgetController,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Object) onError,
    required Function(Map<String, dynamic>) onFallback,
    required Function(Object) onFallbackError,
  }) async {
    // Try Together AI first
    try {
      final primaryResponse = await _makePrimaryApiCall(
        ideaController.text,
        budgetController.text,
      );

      try {
        final sanitizedResponse = _sanitizeJsonResponse(primaryResponse);
        final jsonResponse = json.decode(sanitizedResponse);

        if (_validateRoadmapStructure(jsonResponse)) {
          onSuccess(jsonResponse);
          return;
        }
      } catch (e) {
        logError('Primary response parsing failed', e);
      }

      try {
        final cleanedResponse = await _makeCleaningApiCall(primaryResponse);
        final sanitizedResponse = _sanitizeJsonResponse(cleanedResponse);
        final jsonResponse = json.decode(sanitizedResponse);

        if (_validateRoadmapStructure(jsonResponse)) {
          onSuccess(jsonResponse);
          return;
        }
      } catch (e) {
        logError('Cleaning API attempt failed', e);
      }
    } catch (e) {
      logError('Together AI failed, trying Gemini', e);
      // If Together AI fails, try Gemini directly for JSON
      try {
        final geminiResponse = await _makeGeminiJsonCall(
          ideaController.text,
          budgetController.text,
        );

        try {
          final sanitizedResponse = _sanitizeJsonResponse(geminiResponse);
          final jsonResponse = json.decode(sanitizedResponse);

          if (_validateRoadmapStructure(jsonResponse)) {
            onSuccess(jsonResponse);
            return;
          }
        } catch (parseError) {
          logError('Gemini JSON response parsing failed', parseError);
        }
      } catch (geminiError) {
        logError('Gemini JSON generation also failed', geminiError);
      }
    }

    // Final fallback to markdown generation
    await fallbackMarkdownGeneration(
      ideaController: ideaController,
      budgetController: budgetController,
      onSuccess: onFallback,
      onError: onFallbackError,
    );
  }

  static Future<String> _makePrimaryApiCall(String idea, String budget) async {
    final currencySymbol = await _getCurrencySymbol();
    final currentDate = _getCurrentDate();

    final prompt = '''
Generate a detailed investment roadmap for: $idea

User's Budget: $budget $currencySymbol
Current Date: $currentDate

Respond STRICTLY in this JSON format:
{
  "idea_validity": "valid/invalid",
  "refinement_suggestions": ["array", "of", "strings"],
  "investment_timeline": [
    {
      "phase": "string",
      "start": "string",
      "end": "string",
      "milestones": ["array", "of", "strings"]
    }
  ],
  "financial_projection": {
    "total_cost": number,
    "expected_revenue": number,
    "yearly_growth": [array, of, numbers]
  },
  "risk_assessment": {
    "score": "low/medium/high",
    "risks": ["array", "of", "strings"],
    "mitigation": ["array", "of", "strings"]
  },
  "word_cloud": ["array", "of", "strings"]
}

IMPORTANT INSTRUCTIONS:
1. Respond ONLY with valid JSON in the exact specified format
2. Do NOT include any markdown formatting like ```
3. Do NOT include any explanatory text outside the JSON structure
4. Ensure all JSON fields are properly escaped
5. Use the current date "$currentDate" when generating timeline dates
6. ALWAYS use the currency symbol "$currencySymbol" for all monetary values
7. The user's budget is: $budget $currencySymbol - scale financial projections accordingly
8. All financial amounts must be in $currencySymbol
''';

    return await _aiService.generateInvestmentRoadmap(prompt);
  }

  static Future<String> _makeGeminiJsonCall(String idea, String budget) async {
    final currencySymbol = await _getCurrencySymbol();
    final currentDate = _getCurrentDate();

    final prompt = '''
Generate a detailed investment roadmap for: $idea

User's Budget: $budget $currencySymbol
Current Date: $currentDate

Respond STRICTLY in this JSON format:
{
  "idea_validity": "valid/invalid",
  "refinement_suggestions": ["array", "of", "strings"],
  "investment_timeline": [
    {
      "phase": "string",
      "start": "string",
      "end": "string",
      "milestones": ["array", "of", "strings"]
    }
  ],
  "financial_projection": {
    "total_cost": number,
    "expected_revenue": number,
    "yearly_growth": [array, of, numbers]
  },
  "risk_assessment": {
    "score": "low/medium/high",
    "risks": ["array", "of", "strings"],
    "mitigation": ["array", "of", "strings"]
  },
  "word_cloud": ["array", "of", "strings"]
}

IMPORTANT INSTRUCTIONS:
1. Respond ONLY with valid JSON in the exact specified format
2. Do NOT include any markdown formatting like ```
3. Do NOT include any explanatory text outside the JSON structure
4. Ensure all JSON fields are properly escaped
5. Use the current date "$currentDate" when generating timeline dates
6. ALWAYS use the currency symbol "$currencySymbol" for all monetary values
7. The user's budget is: $budget $currencySymbol - scale financial projections accordingly
8. All financial amounts must be in $currencySymbol
''';

    return await _aiService.generateInvestmentRoadmap(prompt);
  }

  static Future<String> _makeCleaningApiCall(String dirtyJson) async {
    return await _aiService.cleanJsonResponse(dirtyJson);
  }

  static Future<void> fallbackMarkdownGeneration({
    required TextEditingController ideaController,
    required TextEditingController budgetController,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Object) onError,
  }) async {
    try {
      final currentDate = _getCurrentDate();
      final currencySymbol = await _getCurrencySymbol();

      // Try first Gemini API key
      try {
        final response = await _callGeminiMarkdownAI(
          ideaController.text,
          budgetController.text,
          currentDate,
          currencySymbol,
          'AIzaSyDg8g0vPWjmVjZeIp9FLLEhPQboQwpHERc',
        );

        final fallbackRoadmap = {
          'idea_validity': 'valid',
          'refinement_suggestions': ['Generated using fallback method'],
          'investment_timeline': [
            {'phase': 'Initial', 'start': 'Immediate', 'end': '3 months'},
          ],
          'financial_projection': {
            'total_cost': 0,
            'expected_revenue': 0,
            'yearly_growth': [0, 0, 0],
          },
          'risk_assessment': {
            'score': 'medium',
            'risks': ['Generated using fallback method'],
            'mitigation': ['See detailed markdown content'],
          },
          'word_cloud': [],
          'markdown_content': response,
        };

        onSuccess(fallbackRoadmap);
        return;
      } catch (e) {
        print('First Gemini markdown API failed: $e');
        // Try second Gemini API key
        final response = await _callGeminiMarkdownAI(
          ideaController.text,
          budgetController.text,
          currentDate,
          currencySymbol,
          'AIzaSyDTA0CQeHhWY7dGl2i2CJuqCCWI4DFc1NM',
        );

        final fallbackRoadmap = {
          'idea_validity': 'valid',
          'refinement_suggestions': ['Generated using fallback method'],
          'investment_timeline': [
            {'phase': 'Initial', 'start': 'Immediate', 'end': '3 months'},
          ],
          'financial_projection': {
            'total_cost': 0,
            'expected_revenue': 0,
            'yearly_growth': [0, 0, 0],
          },
          'risk_assessment': {
            'score': 'medium',
            'risks': ['Generated using fallback method'],
            'mitigation': ['See detailed markdown content'],
          },
          'word_cloud': [],
          'markdown_content': response,
        };

        onSuccess(fallbackRoadmap);
      }
    } catch (e) {
      onError(e);
    }
  }

  static Future<String> _callGeminiMarkdownAI(
    String investmentIdea,
    String budget,
    String currentDate,
    String currencySymbol,
    String apiKey,
  ) async {
    final prompt = _createFallbackPrompt(
        investmentIdea, budget, currentDate, currencySymbol);

    return await _aiService.generateInvestmentRoadmap(prompt);
  }

  static String _sanitizeJsonResponse(String rawResponse) {
    final withoutMarkdown = rawResponse
        .replaceAll(RegExp(r'```json'), '')
        .replaceAll(RegExp(r'```'), '')
        .trim();

    final jsonStart = withoutMarkdown.indexOf('{');
    final jsonEnd = withoutMarkdown.lastIndexOf('}');

    if (jsonStart >= 0 && jsonEnd > jsonStart) {
      return withoutMarkdown.substring(jsonStart, jsonEnd + 1);
    }

    return withoutMarkdown;
  }

  static bool _validateRoadmapStructure(Map<String, dynamic> data) {
    return data.containsKey('idea_validity') &&
        data.containsKey('investment_timeline') &&
        data.containsKey('financial_projection') &&
        data.containsKey('risk_assessment');
  }

  static String _createFallbackPrompt(
    String investmentIdea,
    String budget,
    String currentDate,
    String currencySymbol,
  ) {
    return '''
    Generate a detailed investment roadmap for: $investmentIdea

    User's Budget: $budget $currencySymbol
    Current Date: $currentDate

    Format as comprehensive Markdown with these sections:
    # Executive Summary
    # Timeline and Phases (relative to $currentDate)
    # Financial Projections (in $currencySymbol)
    # Risk Assessment
    # Market Analysis
    # Implementation Strategy
    # Conclusion

    Key Requirements:
    - All monetary values must be in $currencySymbol
    - Scale financial projections based on the $budget $currencySymbol budget
    - Use relative dates from $currentDate
    - Include tables for financial data
    - Use bullet points for clarity
    ''';
  }
}
