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
  final TextEditingController _budgetController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final scaffoldKey =
      GlobalKey<ScaffoldMessengerState>(); // Added for snackbars

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
    _setupControllerListeners();
  }

  void _setupControllerListeners() {
    _ideaController.addListener(() {
      if (_errorMessage != null) {
        setState(() => _errorMessage = null);
      }
    });
    _budgetController.addListener(() {
      if (_errorMessage != null) {
        setState(() => _errorMessage = null);
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: isError
            ? SnackBarAction(
                label: 'DISMISS',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }

  Future<void> _loadDailyUsage() async {
    try {
      await DailyUsageManager.loadDailyUsage(
        key: DAILY_USAGE_KEY,
        onSuccess: (count) {
          setState(() => _dailyUsageCount = count);
        },
        onError: (e) {
          logError('Error loading daily usage', e);
          setState(() => _dailyUsageCount = 0);
          _showSnackBar('Failed to load daily usage count', isError: true);
        },
      );
    } catch (e) {
      logError('Unexpected error in _loadDailyUsage', e);
      _showSnackBar('An unexpected error occurred', isError: true);
    }
  }

  Future<void> _incrementDailyUsage() async {
    try {
      await DailyUsageManager.incrementDailyUsage(
        key: DAILY_USAGE_KEY,
        currentCount: _dailyUsageCount,
        onSuccess: (newCount) {
          setState(() => _dailyUsageCount = newCount);
        },
        onError: (e) {
          logError('Error incrementing daily usage', e);
          _showSnackBar('Failed to update usage count', isError: true);
        },
      );
    } catch (e) {
      logError('Unexpected error in _incrementDailyUsage', e);
      _showSnackBar('An unexpected error occurred', isError: true);
    }
  }

  bool _validateInputs() {
    if (_ideaController.text.length < 15) {
      _showSnackBar('Investment idea must be at least 15 characters long',
          isError: true);
      return false;
    }

    if (_ideaController.text.split(' ').length < 10) {
      _showSnackBar('Investment idea must contain at least 10 words',
          isError: true);
      return false;
    }

    if (_budgetController.text.isEmpty) {
      _showSnackBar('Budget cannot be empty', isError: true);
      return false;
    }

    if (double.tryParse(_budgetController.text) == null) {
      _showSnackBar('Please enter a valid budget amount', isError: true);
      return false;
    }

    if (_dailyUsageCount >= MAX_DAILY_ROADMAPS) {
      _showSnackBar('Daily limit reached. Try again tomorrow!', isError: true);
      return false;
    }

    return true;
  }

  Future<void> _generateRoadmap() async {
    if (_isLoading) {
      _showSnackBar('Please wait, already generating...', isError: true);
      return;
    }

    if (!_validateInputs()) return;

    setState(() {
      _isLoading = true;
      _roadmapData = null;
      _errorMessage = null;
      _isSecondaryAPIAttempt = false;
    });

    try {
      await RoadmapGenerator.generateRoadmap(
        ideaController: _ideaController,
        budgetController: _budgetController,
        onSuccess: (data) async {
          setState(() {
            _roadmapData = data;
            _isLoading = false;
          });
          await _incrementDailyUsage();
          _showSnackBar('Roadmap generated successfully!');
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
          _showSnackBar('Roadmap generated using fallback system');
        },
        onFallbackError: (e) {
          logError('Fallback API call error', e);
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Failed to generate roadmap. Please try again later.';
          });
          _showSnackBar('Failed to generate roadmap', isError: true);
        },
      );
    } catch (e) {
      logError('Unexpected error in _generateRoadmap', e);
      setState(() => _isLoading = false);
      _showSnackBar('An unexpected error occurred', isError: true);
    }
  }

  Future<void> _fallbackMarkdownGeneration() async {
    if (_isSecondaryAPIAttempt) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to generate roadmap after multiple attempts.';
      });
      _showSnackBar('Failed to generate roadmap after multiple attempts',
          isError: true);
      return;
    }

    setState(() => _isSecondaryAPIAttempt = true);

    try {
      await RoadmapGenerator.fallbackMarkdownGeneration(
        ideaController: _ideaController,
        budgetController: _budgetController,
        onSuccess: (fallbackData) async {
          setState(() {
            _roadmapData = fallbackData;
            _isLoading = false;
          });
          await _incrementDailyUsage();
          _showSnackBar('Roadmap generated using backup system');
        },
        onError: (e) {
          logError('Fallback API call error', e);
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Failed to generate roadmap. Please try again later.';
          });
          _showSnackBar('All attempts to generate roadmap failed',
              isError: true);
        },
      );
    } catch (e) {
      logError('Unexpected error in _fallbackMarkdownGeneration', e);
      setState(() => _isLoading = false);
      _showSnackBar('An unexpected error occurred', isError: true);
    }
  }

  Future<void> _exportRoadmapToPDF() async {
    if (_roadmapData == null) {
      _showSnackBar('No roadmap data to export', isError: true);
      return;
    }

    try {
      await PDFGenerator.exportRoadmapToPDF(
        context: context,
        roadmapData: _roadmapData!,
        ideaController: _ideaController,
        onError: (e) {
          logError('PDF generation error', e);
          _showSnackBar('Failed to generate PDF: ${e.toString()}',
              isError: true);
        },
      );
    } catch (e) {
      logError('Unexpected error in _exportRoadmapToPDF', e);
      _showSnackBar('Failed to export PDF', isError: true);
    }
  }

  Future<void> _downloadMarkdownFile() async {
    if (_roadmapData == null ||
        !_roadmapData!.containsKey('markdown_content')) {
      _showSnackBar('No markdown content available', isError: true);
      return;
    }

    try {
      await PDFGenerator.downloadMarkdownFile(
        roadmapData: _roadmapData!,
        onError: (e) {
          logError('Error downloading markdown file', e);
          _showSnackBar('Failed to download file: ${e.toString()}',
              isError: true);
        },
      );
    } catch (e) {
      logError('Unexpected error in _downloadMarkdownFile', e);
      _showSnackBar('Failed to download markdown', isError: true);
    }
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
                    icon: const Icon(Icons.description),
                    tooltip: 'Download Markdown',
                    onPressed: _downloadMarkdownFile,
                  ),
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
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
                const SizedBox(height: 16),
                InvestmentIdeaInput(
                  ideaController: _ideaController,
                  budgetController: _budgetController,
                  isLoading: _isLoading,
                  onGenerateRoadmap: _generateRoadmap,
                  isDarkMode: isDarkMode,
                  theme: theme,
                ),
                const SizedBox(height: 16),
                if (_errorMessage != null)
                  ErrorMessage(message: _errorMessage!),
                const SizedBox(height: 16),
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
    _budgetController.dispose();
    super.dispose();
  }
}
