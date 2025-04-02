import 'package:flutter/material.dart';

class InvestmentIdeaInput extends StatefulWidget {
  final TextEditingController ideaController;
  final TextEditingController budgetController;
  final bool isLoading;
  final VoidCallback onGenerateRoadmap;
  final bool isDarkMode;
  final ThemeData theme;

  const InvestmentIdeaInput({
    Key? key,
    required this.ideaController,
    required this.budgetController,
    required this.isLoading,
    required this.onGenerateRoadmap,
    required this.isDarkMode,
    required this.theme,
  }) : super(key: key);

  @override
  State<InvestmentIdeaInput> createState() => _InvestmentIdeaInputState();
}

class _InvestmentIdeaInputState extends State<InvestmentIdeaInput> {
  bool _isIdeaValid = false;
  bool _isBudgetValid = false;

  @override
  void initState() {
    super.initState();
    widget.ideaController.addListener(_validateIdea);
    widget.budgetController.addListener(_validateBudget);
  }

  void _validateIdea() {
    final isValid = widget.ideaController.text.length >= 15 &&
        widget.ideaController.text.split(' ').length >= 10;
    if (isValid != _isIdeaValid) {
      setState(() => _isIdeaValid = isValid);
    }
  }

  void _validateBudget() {
    final isValid = widget.budgetController.text.isNotEmpty &&
        double.tryParse(widget.budgetController.text) != null;
    if (isValid != _isBudgetValid) {
      setState(() => _isBudgetValid = isValid);
    }
  }

  String? _getIdeaError() {
    final text = widget.ideaController.text;
    if (text.isEmpty) return null;
    if (text.length < 15) {
      return 'Must be at least 15 characters';
    }
    if (text.split(' ').length < 10) {
      return 'Must contain at least 10 words';
    }
    return null;
  }

  String? _getBudgetError() {
    final text = widget.budgetController.text;
    if (text.isEmpty) return null;
    if (double.tryParse(text) == null) {
      return 'Must be a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Describe Your Investment Idea',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: widget.ideaController,
              decoration: InputDecoration(
                hintText:
                    'E.g., "A subscription service for premium coffee beans delivered monthly with personalized recommendations"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.theme.colorScheme.primary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isIdeaValid
                        ? Colors.green
                        : widget.theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: widget.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade50,
                contentPadding: EdgeInsets.all(16),
                errorText: _getIdeaError(),
                suffixIcon: _isIdeaValid
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              maxLines: 4,
              style: TextStyle(fontSize: 16),
              onChanged: (_) => setState(() {}),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Row(
                children: [
                  Icon(
                    _isIdeaValid ? Icons.check : Icons.info_outline,
                    size: 16,
                    color: _isIdeaValid ? Colors.green : Colors.grey,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Minimum 15 characters and 10 words',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isIdeaValid ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Input Budget (\\KES)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: widget.budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'E.g., 5000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: widget.theme.colorScheme.primary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: _isBudgetValid
                        ? Colors.green
                        : widget.theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: widget.isDarkMode
                    ? Colors.grey.shade900
                    : Colors.grey.shade50,
                contentPadding: EdgeInsets.all(16),
                errorText: _getBudgetError(),
                suffixIcon: _isBudgetValid
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
              ),
              style: TextStyle(fontSize: 16),
              onChanged: (_) => setState(() {}),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onGenerateRoadmap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.theme.colorScheme.primary,
                  foregroundColor: widget.theme.colorScheme.onPrimary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: widget.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: widget.theme.colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Generating Roadmap...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Generate Investment Roadmap',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.ideaController.removeListener(_validateIdea);
    widget.budgetController.removeListener(_validateBudget);
    super.dispose();
  }
}
