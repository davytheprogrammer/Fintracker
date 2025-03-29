import 'package:flutter/material.dart';

import 'daily_usage_manager.dart';
import 'roadmap_generator.dart';
import 'error_logger.dart';
import 'pdf_generator.dart';
import 'ui_elements.dart';

class InvestmentsPage extends StatefulWidget {
  const InvestmentsPage({Key? key}) : super(key: key);

  @override
  _InvestmentsPageState createState() => _InvestmentsPageState();
}

class _InvestmentsPageState extends State<InvestmentsPage> {
  final TextEditingController _ideaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  Map<String, dynamic>? _roadmapData;
  int _dailyUsageCount = 0;
  String? _errorMessage;
  bool _isSecondaryAPIAttempt = false;

  static const int MAX_DAILY_ROADMAPS = 6;
  static const String DAILY_USAGE_KEY = 'daily_roadmap_usage';

  @override
  void initState() {
    super.initState();
    _loadDailyUsage();
  }

  Future<void> _loadDailyUsage() async {
    await DailyUsageManager.loadDailyUsage(
      key: DAILY_USAGE_KEY,
      onSuccess: (count) {
        setState(() {
          _dailyUsageCount = count;
        });
      },
      onError: (e) {
        logError('Error loading daily usage', e);
        setState(() {
          _dailyUsageCount = 0;
        });
      },
    );
  }

  Future<void> _incrementDailyUsage() async {
    await DailyUsageManager.incrementDailyUsage(
      key: DAILY_USAGE_KEY,
      currentCount: _dailyUsageCount,
      onSuccess: (newCount) {
        setState(() {
          _dailyUsageCount = newCount;
        });
      },
      onError: (e) {
        logError('Error incrementing daily usage', e);
      },
    );
  }

  Future<void> _generateRoadmap() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dailyUsageCount >= MAX_DAILY_ROADMAPS) {
      _showDailyLimitDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _roadmapData = null;
      _errorMessage = null;
      _isSecondaryAPIAttempt = false;
    });

    await RoadmapGenerator.generateRoadmap(
      ideaController: _ideaController,
      onSuccess: (data) async {
        setState(() {
          _roadmapData = data;
          _isLoading = false;
        });
        await _incrementDailyUsage();
      },
      onError: (e) async {
        logError('Primary API call error', e);
        await _fallbackMarkdownGeneration();
      },
      onFallback: (fallbackData) async {
        setState(() {
          _roadmapData = fallbackData;
          _isLoading = false;
        });
        await _incrementDailyUsage();
      },
      onFallbackError: (e) {
        logError('Fallback API call error', e);
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to generate roadmap. Please try again later.';
        });
      },
    );
  }

  Future<void> _fallbackMarkdownGeneration() async {
    if (_isSecondaryAPIAttempt) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to generate roadmap after multiple attempts.';
      });
      return;
    }

    setState(() {
      _isSecondaryAPIAttempt = true;
    });

    await RoadmapGenerator.fallbackMarkdownGeneration(
      ideaController: _ideaController,
      onSuccess: (fallbackData) async {
        setState(() {
          _roadmapData = fallbackData;
          _isLoading = false;
        });
        await _incrementDailyUsage();
      },
      onError: (e) {
        logError('Fallback API call error', e);
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to generate roadmap. Please try again later.';
        });
      },
    );
  }

  void _showDailyLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Daily Limit Reached'),
        content: Text(
            'You\'ve reached your daily limit of 3 roadmaps. Try again tomorrow.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          )
        ],
      ),
    );
  }

  Future<void> _exportRoadmapToPDF() async {
    if (_roadmapData == null) return;

    await PDFGenerator.exportRoadmapToPDF(
      roadmapData: _roadmapData!,
      ideaController: _ideaController,
      onError: (e) {
        logError('PDF generation error', e);
        _showErrorDialog('Error generating PDF: ${e.toString()}');
      },
    );
  }

  Future<void> _downloadMarkdownFile() async {
    if (_roadmapData == null || !_roadmapData!.containsKey('markdown_content'))
      return;

    await PDFGenerator.downloadMarkdownFile(
      roadmapData: _roadmapData!,
      onError: (e) {
        logError('Error downloading markdown file', e);
        _showErrorDialog('Error downloading file: ${e.toString()}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Investment Roadmap Generator',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          if (_roadmapData != null)
            Row(
              children: [
                if (_roadmapData!.containsKey('markdown_content'))
                  IconButton(
                    icon: Icon(Icons.description),
                    tooltip: 'Download Markdown',
                    onPressed: _downloadMarkdownFile,
                  ),
                IconButton(
                  icon: Icon(Icons.picture_as_pdf),
                  tooltip: 'Export to PDF',
                  onPressed: _exportRoadmapToPDF,
                ),
              ],
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.grey.shade900, Colors.black]
                : [Colors.pink.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DailyUsageIndicator(
                  dailyUsageCount: _dailyUsageCount,
                  maxDailyRoadmaps: MAX_DAILY_ROADMAPS,
                  isDarkMode: isDarkMode,
                  theme: theme,
                ),
                SizedBox(height: 16),
                InvestmentIdeaInput(
                  ideaController: _ideaController,
                  isLoading: _isLoading,
                  dailyUsageCount: _dailyUsageCount,
                  maxDailyRoadmaps: MAX_DAILY_ROADMAPS,
                  onGenerateRoadmap: _generateRoadmap,
                  isDarkMode: isDarkMode,
                  theme: theme,
                ),
                SizedBox(height: 16),
                if (_errorMessage != null)
                  ErrorMessage(message: _errorMessage!),
                SizedBox(height: 16),
                if (_roadmapData != null) ...[
                  if (_roadmapData!.containsKey('markdown_content'))
                    MarkdownSection(roadmapData: _roadmapData!),
                  if (!_roadmapData!.containsKey('markdown_content')) ...[
                    TimelineSection(roadmapData: _roadmapData!),
                    FinancialBreakdown(roadmapData: _roadmapData!),
                    RiskAssessment(roadmapData: _roadmapData!),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ideaController.dispose();
    super.dispose();
  }
}
