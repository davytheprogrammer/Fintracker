import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';

import 'error_logger.dart';

class RoadmapGenerator {
  static Future<void> generateRoadmap({
    required TextEditingController ideaController,
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Object) onError,
    required Function(Map<String, dynamic>) onFallback,
    required Function(Object) onFallbackError,
  }) async {
    try {
      // First attempt with strict instructions
      final primaryResponse = await _makePrimaryApiCall(ideaController.text);

      // Try parsing the primary response
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

      // If primary fails, try cleaning with secondary API
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

      // If both attempts fail, fall back to markdown
      await fallbackMarkdownGeneration(
        ideaController: ideaController,
        onSuccess: onFallback,
        onError: onFallbackError,
      );
    } catch (e) {
      logError('Roadmap generation failed', e);
      await fallbackMarkdownGeneration(
        ideaController: ideaController,
        onSuccess: onFallback,
        onError: onFallbackError,
      );
    }
  }

  static Future<String> _makePrimaryApiCall(String idea) async {
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

    final prompt = '''
    $strictInstructions
    
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
    required Function(Map<String, dynamic>) onSuccess,
    required Function(Object) onError,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: 'AIzaSyCOutG-g_tVZKzbTtH0bzNjWdoaDVA2YCo',
      );

      final response = await model.generateContent(
          [Content.text(_createFallbackPrompt(ideaController.text))]);

      final fallbackRoadmap = {
        'idea_validity': 'valid',
        'refinement_suggestions': ['Generated using fallback method'],
        'investment_timeline': [
          {'phase': 'Initial', 'start': 'Immediate', 'end': '3 months'}
        ],
        'financial_projection': {
          'total_cost': 0,
          'expected_revenue': 0,
          'yearly_growth': [0, 0, 0]
        },
        'risk_assessment': {
          'score': 'medium',
          'risks': ['Generated using fallback method'],
          'mitigation': ['See detailed markdown content']
        },
        'word_cloud': [],
        'markdown_content': response.text ?? ''
      };

      onSuccess(fallbackRoadmap);
    } catch (e) {
      onError(e);
    }
  }

  static String _sanitizeJsonResponse(String rawResponse) {
    // Remove all markdown code blocks
    final withoutMarkdown = rawResponse
        .replaceAll(RegExp(r'```json'), '')
        .replaceAll(RegExp(r'```'), '')
        .trim();

    // Remove any non-JSON content before/after
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

  static String _createFallbackPrompt(String investmentIdea) {
    return '''
    Generate a detailed investment roadmap for: $investmentIdea
    
    Format as comprehensive Markdown with these sections:
    # Executive Summary
    # Timeline and Phases
    # Financial Projections
    # Risk Assessment
    # Market Analysis
    # Implementation Strategy
    # Conclusion
    
    Use bullet points, tables, and clear organization.
    Include relevant icons to make it look cooler.
    ''';
  }
}
