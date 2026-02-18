import 'package:flutter/material.dart';
import '../../shared/constants.dart';

class InvestmentIdeaInput extends StatefulWidget {
  final TextEditingController ideaController;
  final TextEditingController budgetController;
  final bool isLoading;
  final VoidCallback onGenerateRoadmap;
  final bool isDarkMode;
  final ThemeData theme;
  final String currencySymbol;

  const InvestmentIdeaInput({
    Key? key,
    required this.ideaController,
    required this.budgetController,
    required this.isLoading,
    required this.onGenerateRoadmap,
    required this.isDarkMode,
    required this.theme,
    this.currencySymbol = 'KES',
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
      decoration: glassCardDecoration(isDark: widget.isDarkMode),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Describe Your Investment Idea',
            style: AppTypography.titleLarge.copyWith(
              color: widget.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: widget.ideaController,
            decoration: modernInputDecoration(
              label: 'Investment Idea',
              icon: Icons.lightbulb_outline,
              hint: 'E.g., "A subscription service for premium coffee beans..."',
              isDark: widget.isDarkMode,
              suffix: _isIdeaValid
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : null,
            ).copyWith(
              errorText: _getIdeaError(),
            ),
            maxLines: 4,
            style: AppTypography.bodyLarge.copyWith(
              color: widget.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            onChanged: (_) => setState(() {}),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.sm),
            child: Row(
              children: [
                Icon(
                  _isIdeaValid ? Icons.check : Icons.info_outline,
                  size: 16,
                  color: _isIdeaValid ? AppColors.success : AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Minimum 15 characters and 10 words',
                  style: AppTypography.bodySmall.copyWith(
                    color: _isIdeaValid ? AppColors.success : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Input Budget',
            style: AppTypography.titleLarge.copyWith(
              color: widget.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: widget.budgetController,
            keyboardType: TextInputType.number,
            decoration: modernInputDecoration(
              label: 'Budget (${widget.currencySymbol})',
              icon: Icons.attach_money,
              hint: 'E.g., 5000',
              isDark: widget.isDarkMode,
              suffix: _isBudgetValid
                  ? const Icon(Icons.check_circle, color: AppColors.success)
                  : null,
            ).copyWith(
              errorText: _getBudgetError(),
            ),
            style: AppTypography.bodyLarge.copyWith(
              color: widget.isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: Container(
              decoration: gradientButtonDecoration(
                colors: AppColors.primaryGradient,
                radius: AppRadius.md,
              ),
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onGenerateRoadmap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: widget.isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Generating Roadmap...',
                            style: AppTypography.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'Generate Investment Roadmap',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
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
