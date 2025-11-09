import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../services/user_services.dart';
import 'error_logger.dart';

class RoadmapGenerator {
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

      await fallbackMarkdownGeneration(
        ideaController: ideaController,
        budgetController: budgetController,
        onSuccess: onFallback,
        onError: onFallbackError,
      );
    } catch (e) {
      logError('Roadmap generation failed', e);
      await fallbackMarkdownGeneration(
        ideaController: ideaController,
        budgetController: budgetController,
        onSuccess: onFallback,
        onError: onFallbackError,
      );
    }
  }

  static Future<String> _makePrimaryApiCall(String idea, String budget) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyCOutG-g_tVZKzbTtH0bzNjWdoaDVA2YCo',
    );

    const strictInstructions = '''
    IMPORTANT INSTRUCTIONS:
    1. Respond ONLY with valid JSON in the exact specified format
    2. Do NOT include any markdown formatting like ```
    3. Do NOT include any explanatory text outside the JSON structure
    4. Ensure all JSON fields are properly escaped
    5. If you must include comments, put them inside JSON strings
    ''';

    final currencySymbol = await _getCurrencySymbol();
    final currentDate = _getCurrentDate();

    final prompt = '''
    $strictInstructions

    ADDITIONAL INSTRUCTIONS:
    1. Use the current date "$currentDate" when generating timeline dates
    2. ALWAYS use the currency symbol "$currencySymbol" for all monetary values
    3. The user's budget is: $budget $currencySymbol - scale financial projections accordingly
    4. If no specific dates are provided, calculate relative to "$currentDate"
    5. All financial amounts must be in $currencySymbol

    ${_createRoadmapPrompt(idea)}
    ''';
    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '{}';
  }

  static Future<String> _makeCleaningApiCall(String dirtyJson) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyCOutG-g_tVZKzbTtH0bzNjWdoaDVA2YCo',
    );

    const cleaningInstructions = '''
    IMPORTANT: Your ONLY task is to fix this JSON response.
    Return ONLY the corrected JSON without any additional text or markdown.
    Preserve all original content while fixing syntax errors.
    Ensure the output is valid JSON that can be parsed by Dart's json.decode().
    ''';

    final prompt = '''
    $cleaningInstructions
    
    Here is the JSON to fix:
    $dirtyJson
    ''';

    final response = await model.generateContent([Content.text(prompt)]);
    return response.text ?? '{}';
  }

  static Future<void> fallbackMarkdownGeneration({
    required TextEditingController ideaController,
    required TextEditingController budgetController,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Object) onError,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyCOutG-g_tVZKzbTtH0bzNjWdoaDVA2YCo',
      );

      final currentDate = _getCurrentDate();

      final currencySymbol = await _getCurrencySymbol();
      final response = await model.generateContent([
        Content.text(
          _createFallbackPrompt(
            ideaController.text,
            budgetController.text,
            currentDate,
            currencySymbol,
          ),
        ),
      ]);

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
        'markdown_content': response.text ?? '',
      };

      onSuccess(fallbackRoadmap);
    } catch (e) {
      onError(e);
    }
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

  static String _createRoadmapPrompt(String investmentIdea) {
    return '''
    Generate a detailed investment roadmap for: $investmentIdea 
    
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
    ''';
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
